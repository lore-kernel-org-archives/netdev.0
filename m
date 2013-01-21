From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v4 2/3] net: split eth_mac_addr for better error handling
Date: Mon, 21 Jan 2013 17:13:28 +0100
Message-ID: <20130121161328.GE24473@stefanha-thinkpad.redhat.com>
References: <1358649789-2338-1-git-send-email-akong@redhat.com>
 <1358649789-2338-3-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org,
	davem@davemloft.net
To: akong@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:49072 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab3AUQNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:13:32 -0500
Content-Disposition: inline
In-Reply-To: <1358649789-2338-3-git-send-email-akong@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 20, 2013 at 10:43:08AM +0800, akong@redhat.com wrote:
> From: Stefan Hajnoczi <stefanha@gmail.com>
> 
> When we set mac address, software mac address in system and hardware mac
> address all need to be updated. Current eth_mac_addr() doesn't allow
> callers to implement error handling nicely.
> 
> This patch split eth_mac_addr() to prepare part and real commit part,
> then we can prepare first, and try to change hardware address, then do
> the real commit if hardware address is set successfully.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@gmail.com>
> Signed-off-by: Amos Kong <akong@redhat.com>
> ---
>  include/linux/etherdevice.h |  2 ++
>  net/ethernet/eth.c          | 43 ++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 38 insertions(+), 7 deletions(-)

Feel free to make yourself author and put me just as Suggested-by:.  I
posted pseudo-code but didn't write the patch or test it, so it's fair
to say that credit goes to you. :)

Stefan

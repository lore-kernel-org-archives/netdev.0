From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RESEND PATCH net-next 1/1] sit: allow to configure 6rd tunnels
 via netlink
Date: Tue, 20 Nov 2012 09:01:13 -0800
Message-ID: <20121120090113.47ce16b5@nehalam.linuxnetplumber.net>
References: <20121120.033405.490869980095149376.davem@davemloft.net>
	<1353400905-28335-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45981 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653Ab2KTRCT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2012 12:02:19 -0500
In-Reply-To: <1353400905-28335-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Nov 2012 09:41:45 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> This patch add the support of 6RD tunnels management via netlink.
> Note that netdev_state_change() is now called when 6RD parameters are updated.
> 
> 6RD parameters are updated only if there is at least one 6RD attribute.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/uapi/linux/if_tunnel.h |   4 ++
>  net/ipv6/sit.c                 | 149 ++++++++++++++++++++++++++++++++++-------
>  2 files changed, 128 insertions(+), 25 deletions(-)
> 

Ok, but iproute2 git is currently for 3.6
Please resubmit when 3.7 is finished during 3.8 merge window.

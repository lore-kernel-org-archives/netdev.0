From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: Forward EAPOL when STP off
Date: Sat, 4 Jun 2011 22:42:09 +0900
Message-ID: <20110604224209.5c784729@s6510.ftrdhcpuser.net>
References: <BANLkTimdK-5tsWcTFbe_-82fHxr4TN4F_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.poirier@gmail.com,
	davem@davemloft.net, shemminger@linux-foundation.org
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55887 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756317Ab1FDNmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2011 09:42:16 -0400
In-Reply-To: <BANLkTimdK-5tsWcTFbe_-82fHxr4TN4F_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Jun 2011 16:59:13 +0100
Nick Carter <ncarter100@gmail.com> wrote:

> Signed-off-by: Nick Carter <ncarter100@gmail.com>
> 
> If STP is disabled then forward frames destined to the 802.1X PAE group
> address (01-80-C2-00-00-03)
> 
> This change is required to support virtual machines running an 802.1X
> supplicant and bridged to an ethernet interface.
> 
> This change has been tested and works fine with a range of supplicants.

No. This is getting messy and starts down the path of the recent
802.3ad change which just got reverted. A better solution is needed
than individual hacky standards breaking. If you really need to do
this, use the "duct tape" of networking ebtables.

See also:
https://lists.linux-foundation.org/pipermail/bridge/2007-November/005638.html

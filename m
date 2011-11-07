From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] usbnet: fix oops in usbnet_start_xmit
Date: Mon, 7 Nov 2011 15:42:04 +0100
Message-ID: <20111107144204.GA344@cherladcori01>
References: <20111106183337.5379.4356.stgit@zurg>
 <20111107133351.GA1484@cherladcori01>
 <4EB7E5A2.2070407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Neukum <oneukum@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>,
	Michael Riesch <michael@riesch.at>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:55647 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691Ab1KGOmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 09:42:16 -0500
Received: by wwf22 with SMTP id 22so4990368wwf.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 06:42:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4EB7E5A2.2070407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 07, 2011 at 06:05:22PM +0400, Konstantin Khlebnikov wrote:
> Richard Cochran wrote:
> >On Sun, Nov 06, 2011 at 10:33:37PM +0300, Konstantin Khlebnikov wrote:
> >>This patch fixes the bug added in commit v3.1-rc7-1055-gf9b491e
> >>SKB can be NULL at this point, at least for cdc-ncm.
> >
> >What? You mean .ndo_start_xmit is called with skb NULL?
> 
> no. cdc_ncm call usbnet_start_xmit with NULL skb from timer handler
> and tx_fixup hook pickup skb from internal context. yeah, it really messy.

You said it.

Can you please submit the fix suggested by Michael and myself?

Thanks,
Richard

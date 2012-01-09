From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Mon, 9 Jan 2012 13:50:34 +0100
Message-ID: <20120109125034.GC4404@cherladcori01>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
 <20120105.132637.2130515220408371607.davem@davemloft.net>
 <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
 <1326095038.2627.4.camel@edumazet-laptop>
 <95DC1AA8EC908B48939B72CF375AA5E3013A99137D@alice.at.omicron.at>
 <20120109124108.GA4404@cherladcori01>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59811 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988Ab2AIMuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 07:50:39 -0500
Received: by werm1 with SMTP id m1so2576903wer.19
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2012 04:50:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20120109124108.GA4404@cherladcori01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2012 at 01:41:08PM +0100, Richard Cochran wrote:
> 
> 	if (((skb->ip_summed == CHECKSUM_PARTIAL) ||
>       	   		vlan_tx_tag_present(skb) ||
> 			unlikely(do_tstamp)) &&
> 			(skb_headroom(skb) < GMAC_FCB_LEN)) {
> 		struct sk_buff *skb_new;
> 		...
> 	}
> 
> IOW, there was always at least GMAC_FCB_LEN bytes in skb_headroom.

And now, you are asking for more space.

Richard

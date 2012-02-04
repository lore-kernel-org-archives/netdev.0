From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case
Date: Sat, 4 Feb 2012 16:30:48 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5C9FD00@EUSAACMS0702.eamcs.ericsson.se>
References: <RE:_[PATCH]_tcp:_RST:_binding_oif_to_iif_for_tcp_v4>
	<1328390556-14906-1-git-send-email-shawn.lu@ericsson.com>
 <20120204.162602.1922697409850241775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:43557 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063Ab2BDVay convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:30:54 -0500
In-Reply-To: <20120204.162602.1922697409850241775.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, will resubmit with right format. 

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Saturday, February 04, 2012 1:26 PM
> To: Shawn Lu
> Cc: eric.dumazet@gmail.com; netdev@vger.kernel.org; xiaoclu@gmail.com
> Subject: Re: [PATCH] tcp_v4_send_reset: binding oif to iif in 
> no sock case
> 
> From: Shawn Lu <shawn.lu@ericsson.com>
> Date: Sat, 4 Feb 2012 13:22:36 -0800
> 
> > +	/*
> > +	 * When socket is gone, all binding information is lost.
> > +	 * routing might fail in this case. using iif for oif to
> > +	 * make sure we can deliver it
> > +	 */
> 
> Comment is poorly formatted, and I'm getting tired of teaching people
> 
> 	/* That comments are formatted like
> 	 * this.
> 	 */
> 
> 	/*
> 	 * Not like this.
> 	 */
> 
> or do you have infinite vertical lines on your monitor so 
> that this empty "/*" line has no impact on your screen real 
> estate like it does for the rest of us?
> 
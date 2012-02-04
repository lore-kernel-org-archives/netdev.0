From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case
Date: Sat, 4 Feb 2012 17:47:09 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5C9FD01@EUSAACMS0702.eamcs.ericsson.se>
References: <RE:_[PATCH]_tcp_v4_send_reset:_binding_oif_to_iif_in_no_sock_case>
	<1328391897-15241-1-git-send-email-shawn.lu@ericsson.com>
 <20120204.164706.1648698930132193786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:50555 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815Ab2BDWrV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 17:47:21 -0500
In-Reply-To: <20120204.164706.1648698930132193786.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,David:

I do appreciate Eric's helpand contribution in this fix. 
I am a newer here. I just don't know how I can give credit to him. I thought
That you will put "Acked-by: Eric Dumazet <eric.dumazet@gmail.com>" to 
Credit his contribution.

Thanks!
Shawn Lu  

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Saturday, February 04, 2012 1:47 PM
> To: Shawn Lu
> Cc: eric.dumazet@gmail.com; netdev@vger.kernel.org; xiaoclu@gmail.com
> Subject: Re: [PATCH] tcp_v4_send_reset: binding oif to iif in 
> no sock case
> 
> From: Shawn Lu <shawn.lu@ericsson.com>
> Date: Sat, 4 Feb 2012 13:44:57 -0800
> 
> > Binding RST packet outgoing interface to incoming interface 
> for tcp v4 
> > when there is no socket associate with it.
> > This has few benefits:
> > 1. tcp_v6_send_reset already did that.
> > 2. This helps tcp connect with SO_BINDTODEVICE set. When 
> connection is 
> > lost, we still able to sending out RST using same interface.
> > 3. we are sending reply, it is most likely to be succeed if iif is 
> > used
> > 
> > Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> 
> Sigh...
> 
> Thanks for giving Eric not credit whatsoever for his 
> contributions and feedback for this fix. :-/
> 
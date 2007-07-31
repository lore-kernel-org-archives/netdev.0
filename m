From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Tue, 31 Jul 2007 15:13:09 +0300
Message-ID: <200707311513.10032.joakim.koskela@hiit.fi>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707311408.15231.joakim.koskela@hiit.fi> <46AF1996.7080401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:57357 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793AbXGaMMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 08:12:10 -0400
In-Reply-To: <46AF1996.7080401@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 31 July 2007 14:14:30 Patrick McHardy wrote:
> Joakim Koskela wrote:
> > Ok, so changing int xfrm[46]_output(struct sk_buff*) to use the right PF
> > & hook based on the skb's [current] family should put things through the
> > right hoops, right?
>
> Almost, in xfrm4_output the conditional calling of the hook should
> only be done for IPv4 and the IPCB is not valid for IPv6 of course.
> Speaking of which, shouldn't the entire cb be zeroed for interfamily
> transforms? xfrm4_tunnel_output only clears out the options, and I
> think your patch didn't touch it at all ..

Right, thanks for pointing out (to my understanding both flags and opts should 
be reset for 6-4, on 4-4 only the opts)!

br ,j

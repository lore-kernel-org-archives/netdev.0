From: James Morris <jmorris@namei.org>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Tue, 6 Mar 2007 14:40:40 -0500 (EST)
Message-ID: <Line.LNX.4.64.0703061439590.24721@d.namei>
References: <200703060147.l261lnjX024435@faith.austin.ibm.com>
 <Line.LNX.4.64.0703052216490.18579@d.namei> <1173201286.3085.80.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, paul.moore@hp.com, vyekkirala@TrustedCS.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:52270 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932310AbXCFTko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 14:40:44 -0500
In-Reply-To: <1173201286.3085.80.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007, Joy Latten wrote:

> > I saw something similar to this some time ago when testing various 
> > failure modes, and discused it with Herbert.
> > 
> > IIRC, there's a larval SA which is not torn down properly by Racoon once 
> > the full SA is established, and the larval SA keeps resending until it 
> > times out.
> > 
> Ok, good to know. 
> I thought a bit more about this last night but am not
> sure best way to fix it. Perhaps a way to keep larval
> SA around until all SAs resulting from xfrm_vec[xfrm_nr]
> are established... oh well, just thinking out loud... :-) 

I think the solution, if this actually the problem, is for the userland 
code to maintain the SAs.


- James
-- 
James Morris
<jmorris@namei.org>

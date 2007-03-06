From: Joy Latten <latten@austin.ibm.com>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Tue, 06 Mar 2007 11:14:46 -0600
Message-ID: <1173201286.3085.80.camel@faith.austin.ibm.com>
References: <200703060147.l261lnjX024435@faith.austin.ibm.com>
	 <Line.LNX.4.64.0703052216490.18579@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, paul.moore@hp.com, vyekkirala@TrustedCS.com
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:33630 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965371AbXCFRcC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 12:32:02 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l26HW0mE023509
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 12:32:00 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l26HUhtT199586
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 12:30:43 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l26HUgHs013200
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 12:30:43 -0500
In-Reply-To: <Line.LNX.4.64.0703052216490.18579@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-03-05 at 22:21 -0500, James Morris wrote:
> On Mon, 5 Mar 2007, Joy Latten wrote:
> 
> > 5. Around the time the set of SAs for OUT direction are to be
> >    inserted into SAD, I see another ACQUIRE happening.
> >    
> >    I have not yet figured out where this second ACQUIRE comes from
> >    and why it happens. As long as the minimal SA or set of valid outgoing
> >    SAs exist in SAD, an ACQUIRE should not happen.
> 
> I saw something similar to this some time ago when testing various 
> failure modes, and discused it with Herbert.
> 
> IIRC, there's a larval SA which is not torn down properly by Racoon once 
> the full SA is established, and the larval SA keeps resending until it 
> times out.
> 
Ok, good to know. 
I thought a bit more about this last night but am not
sure best way to fix it. Perhaps a way to keep larval
SA around until all SAs resulting from xfrm_vec[xfrm_nr]
are established... oh well, just thinking out loud... :-) 


Joy

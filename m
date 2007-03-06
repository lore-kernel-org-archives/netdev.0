From: James Morris <jmorris@namei.org>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Mon, 5 Mar 2007 22:21:20 -0500 (EST)
Message-ID: <Line.LNX.4.64.0703052216490.18579@d.namei>
References: <200703060147.l261lnjX024435@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, paul.moore@hp.com, vyekkirala@TrustedCS.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:44038 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933904AbXCFDVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 22:21:24 -0500
In-Reply-To: <200703060147.l261lnjX024435@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Mar 2007, Joy Latten wrote:

> 5. Around the time the set of SAs for OUT direction are to be
>    inserted into SAD, I see another ACQUIRE happening.
>    
>    I have not yet figured out where this second ACQUIRE comes from
>    and why it happens. As long as the minimal SA or set of valid outgoing
>    SAs exist in SAD, an ACQUIRE should not happen.

I saw something similar to this some time ago when testing various 
failure modes, and discused it with Herbert.

IIRC, there's a larval SA which is not torn down properly by Racoon once 
the full SA is established, and the larval SA keeps resending until it 
times out.



- James
-- 
James Morris
<jmorris@namei.org>

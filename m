From: Joy Latten <latten@austin.ibm.com>
Subject: Re: IPsec replay sequence number overflow behavior? (RFC4303 section 3.3.3)
Date: Wed, 19 Dec 2007 00:36:40 -0600
Message-ID: <200712190636.lBJ6ae2a024167@faith.austin.ibm.com>
Cc: herbert@gondor.apana.org.au, kaber@trash.net, latten@us.ibm.com,
	netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:52442 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457AbXLSGhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 01:37:48 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBJ6bjLw006252
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 01:37:45 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBJ6bjYv452798
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 01:37:45 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBJ6biRF013683
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 01:37:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Rereading the thread it's unclear to me which solution was deemed "correct".  
>I'm not a big fan of fiddling/forcing SA lifetimes unless we have no other 
>option; if someone is foolish enough to use manual keying with replay 
>protection and no mechanism to catch rollover then they most likely have 
>larger problems.  It's the whole "we'll provide you with the gun, but you 
>have to shoot yourself" argument as applied to SA lifetimes.

Also, the ipsec rfc require auotmated SA management when 
using anti-replay service and that the option be disabled 
when SAs are manually setup.

It may not stop anyone, but we can always point to rfc. :-)

Joy


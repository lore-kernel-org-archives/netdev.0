From: Joy Latten <latten@austin.ibm.com>
Subject: Re: Labeled IPsec with NAT
Date: Tue, 11 Dec 2007 23:03:10 -0600
Message-ID: <200712120503.lBC53AYb028820@faith.austin.ibm.com>
Cc: netdev@vger.kernel.org
To: sreeniva@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:40102 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbXLLFER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 00:04:17 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBC54EdS016914
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 00:04:14 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBC54EEb126294
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 00:04:14 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBC54Dh6002856
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 00:04:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>I am working on setting up Labeled IPsec along with iptables nat  
>rules. Once I insert nat related rules, the ipsec connection breaks  
>and the system tries to re-negotiate and creates multiple SAs. I am  
>using 2.6.19 kernel (with Venkat's MLSXFRM patches & bugfixes). I  
>guess those were incorporated into the 2.6.20 kernel.

Are you using racoon in ipsec-tools to create labeled SAs?
If so, I recall seeing duplicate SA pairs being created
while using racoon for labeled ipsec. We determined userspace
should manage this.
I posted a patch to ipsec-tools, but I don't think they
ever picked it up... I do not know if this is same problem,
but you could give it a try.

regards,
Joy

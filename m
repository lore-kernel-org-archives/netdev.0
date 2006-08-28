From: Joy Latten <latten@austin.ibm.com>
Subject: Re: IPSec kernel oops on ppc64
Date: Mon, 28 Aug 2006 17:25:15 -0500
Message-ID: <200608282225.k7SMPF80022173@faith.austin.ibm.com>
Cc: davem@davemloft.net, gcwilson@us.ibm.com, jmorris@redhat.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:3054 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964863AbWH1WgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 18:36:20 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SMaIDx017552
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 18:36:18 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SMaIb3239412
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 18:36:18 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SMaIDc011088
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 18:36:18 -0400
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Joy Latten <latten@austin.ibm.com> wrote:
>> I installed 2.6.17 + patch-2.6.18-rc4 + 2.6.18-rc4-mm2
>> onto two pSeries power 5 (ppc64 lpars) machines. I configured
>> IPSec using the configuration listed below. 
>
>Could you try straight 2.6.17? If that crashes too, then at least we
>can be sure that it isn't something new.

A straight 2.6.17 kernel does not crash and my pings work.
A 2.6.17 + patch-2.6.18-rc4 does crash and my pings do not work.
The above tests were done on a ppc64. 
I can try patch-2.6.18-rc1, etc... to see which one it stops
working on to narrow it down.

Regards,
Joy


From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 22:01:17 +0200
Message-ID: <483DBA0D.8090402@gmail.com>
References: <200805270325.24323.opurdila@ixiacom.com> <200805282008.02136.opurdila@ixiacom.com> <20080528175110.GA6210@2ka.mipt.ru> <200805282102.02805.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:23217 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003AbYE1UBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 16:01:50 -0400
Received: by ug-out-1314.google.com with SMTP id h2so218494ugf.16
        for <netdev@vger.kernel.org>; Wed, 28 May 2008 13:01:44 -0700 (PDT)
In-Reply-To: <200805282102.02805.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote, On 05/28/2008 08:02 PM:

> On Wednesday 28 May 2008, Evgeniy Polyakov wrote:
> 
>> We queue data under the lock and clone appropriate skb (and then grab it
>> multiple times), so even it will be dropped, its data will not freed, and
>> thus we will be able to read it. Or you are talking about different
>> skbs?
> 
> You are right, I forgot about the clone.
> 

Probably I miss something, but how does it help when tcp_collapse()
uses __kfree_skb()?

Regards,
Jarek P.

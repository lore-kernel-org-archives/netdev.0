From: Ben Greear <greearb@candelatech.com>
Subject: Re: hard_start_xmit  conext
Date: Wed, 16 Aug 2006 01:48:56 -0700
Message-ID: <44E2DBF8.8040500@candelatech.com>
References: <E1GDBlk-0006O1-00@gondolin.me.apana.org.au> <44E2CB10.9080701@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	kiran kandi <kkiran78@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:4777 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751018AbWHPIt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 04:49:28 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44E2CB10.9080701@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Herbert Xu wrote:
> 
>> kiran kandi <kkiran78@hotmail.com> wrote:
>>
>>> In what context hard_start_xmit  function is called. Is it called in 
>>> soft irq or a  processes context.
>>
>>
>> softirq

It can be process too...doesn't pktgen call it directly?

Ben


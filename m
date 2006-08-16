From: Jeff Garzik <jeff@garzik.org>
Subject: Re: hard_start_xmit  conext
Date: Wed, 16 Aug 2006 03:36:48 -0400
Message-ID: <44E2CB10.9080701@garzik.org>
References: <E1GDBlk-0006O1-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kiran kandi <kkiran78@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:736 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750934AbWHPHhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 03:37:07 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GDBlk-0006O1-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> kiran kandi <kkiran78@hotmail.com> wrote:
>> In what context hard_start_xmit  function is called. Is it called in soft 
>> irq or a  processes context.
> 
> softirq
> 
>> Also can you call kfree_skb in  soft irq context.
> 
> Yes.  Don't do it in hard irq context though.

FWIW there is also Documentation/networking/netdevices.txt where this 
sort of stuff is documented.

	Jeff



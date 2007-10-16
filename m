From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] [NET_CLS_ACT] Use skb_act_clone
Date: Tue, 16 Oct 2007 16:10:36 +0200
Message-ID: <4714C65C.8070208@trash.net>
References: <1192537921.4480.80.camel@localhost> <4714B445.1020900@trash.net> <1192540951.4480.108.camel@localhost> <20071016140619.GA11763@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42242 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932580AbXJPOK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:10:57 -0400
In-Reply-To: <20071016140619.GA11763@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Oct 16, 2007 at 09:22:31AM -0400, jamal wrote:
>> Does the copying of tc_verd in __copy_skb_header() not cover that?
> 
> Yep, I'm pretty sure it does.
> 
> In fact this patch completely resolves my concerns about tc_verd.


Indeed, I was looking at the wrong tree :)

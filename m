From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/10] [NET]: Avoid unnecessary cloning for ingress
	filtering
Date: Tue, 16 Oct 2007 06:28:02 -0400
Message-ID: <1192530482.4480.17.camel@localhost>
References: <20071014042604.GA11431@gondor.apana.org.au>
	 <E1Igv4p-00030c-00@gondolin.me.apana.org.au>
	 <1192358991.4892.23.camel@localhost> <1192456665.4336.57.camel@localhost>
	 <20071015145527.GA11689@ms2.inr.ac.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.226]:33958 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675AbXJPK2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 06:28:33 -0400
Received: by nz-out-0506.google.com with SMTP id s18so1178437nze
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 03:28:32 -0700 (PDT)
In-Reply-To: <20071015145527.GA11689@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-15-10 at 18:55 +0400, Alexey Kuznetsov wrote:
> Hello!

Didnt mean to wake you up Alexey ;->

> I see not so many places inside net/sched/act* where skb_clone is used.
> Exactly one in act_mirred.c, to be more exact. Did I miss something?

No you are right, thats the only spot at the moment. 
What i meant however was the design-intent/enviromental-rules for all
actions that branch is to clone, and when you do that you reset those
fields i described. I am looking at the new clone and i can see
Herbert's point - it does look less pleasant to stare at with that
#ifdef; i will send a patch to pull it out and also write a small doc to
describe the environmental rules.

cheers,
jamal


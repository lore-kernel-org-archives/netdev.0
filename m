From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 03 Jan 2008 06:23:22 -0500
Message-ID: <1199359402.4710.17.camel@localhost>
References: <20080103095829.GB2000@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:30242 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbYACLXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 06:23:25 -0500
Received: by py-out-1112.google.com with SMTP id u52so10440468pyb.10
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2008 03:23:24 -0800 (PST)
In-Reply-To: <20080103095829.GB2000@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-01 at 10:58 +0100, Jarek Poplawski wrote:
> On 02-01-2008 17:01, Paul Moore wrote:

> > This patch is needed by some of the labeled networking changes proposed for
> > 2.6.25, does anyone have any objections?
> 
> Probably Jamal could be the most interested (added to CC):
> 

Gracias Jarek.
Paul, (out of curiosity more than anything) what are the circumstances
of the cloned skb - are you going to reinject it back at some point?

I cant think of any good reason why iif shouldnt be copied - thats how
its been from the begining (dammit;->). The reason it hasnt mattered so
far is everything that needs to write the iif never copied (refer to 
Documentation/networking/tc-actions-env-rules.txt). For correctness i
think it should be copied. So no objections;
The better patch would be to just put it in skb_clone and remove it from
tc_act_clone.

cheers,
jamal


From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1]core:Change a wrong explain about dev_get_by_name
Date: Wed, 20 Mar 2013 17:10:43 +0000
Message-ID: <1363799443.2677.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <CA+qZnSSMfbeGsThYe-=tK-kZ3h1GEKDGkNom+07-hRSqgLUUWg@mail.gmail.com>
	 <1363793549.3333.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tingwei liu <tingw.liu@gmail.com>, <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63839 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263Ab3CTRKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:10:49 -0400
In-Reply-To: <1363793549.3333.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 08:32 -0700, Eric Dumazet wrote:
> On Wed, 2013-03-20 at 17:33 +0800, tingwei liu wrote:
> > From 5d787e8c3725efa6af3036eeb52aba1905c70de9 Mon Sep 17 00:00:00 2001
> > From: root <root@linux-19.site>
> > Date: Wed, 20 Mar 2013 17:39:59 +0800
> > Subject: [PATCH] Change a wrong explain about dev_get_by_name
> > 
> 
> No changelog ? This patch really needs a changelog.
> 
> I have no idea why we should document this function being not safe in
> irq context.
> 
> Most part of networking stack is non safe in hard irq context.
> 
> Should we add a comment in front of all possible entry points ?

If they are wrongly documented as 'can be called from any context', yes.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

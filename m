From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1]core:Change a wrong explain about dev_get_by_name
Date: Wed, 20 Mar 2013 08:32:29 -0700
Message-ID: <1363793549.3333.12.camel@edumazet-glaptop>
References: <CA+qZnSSMfbeGsThYe-=tK-kZ3h1GEKDGkNom+07-hRSqgLUUWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	davem@davemloft.net
To: tingwei liu <tingw.liu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:65211 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab3CTPdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 11:33:09 -0400
Received: by mail-qc0-f178.google.com with SMTP id d10so215517qca.23
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 08:33:08 -0700 (PDT)
In-Reply-To: <CA+qZnSSMfbeGsThYe-=tK-kZ3h1GEKDGkNom+07-hRSqgLUUWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 17:33 +0800, tingwei liu wrote:
> From 5d787e8c3725efa6af3036eeb52aba1905c70de9 Mon Sep 17 00:00:00 2001
> From: root <root@linux-19.site>
> Date: Wed, 20 Mar 2013 17:39:59 +0800
> Subject: [PATCH] Change a wrong explain about dev_get_by_name
> 

No changelog ? This patch really needs a changelog.

I have no idea why we should document this function being not safe in
irq context.

Most part of networking stack is non safe in hard irq context.

Should we add a comment in front of all possible entry points ?

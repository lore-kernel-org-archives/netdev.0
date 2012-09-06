From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Small bug on rxhash calculation
Date: Thu, 06 Sep 2012 08:42:13 +0200
Message-ID: <1346913733.13121.179.camel@edumazet-glaptop>
References: <CAEb0MffEfboq_VmPFCtzGHe-SQ4Dd1O6Hptrc_jHVnp7itKyQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, edumazet@google.com,
	Chema Gonzalez <chema@google.com>
To: Chema Gonzalez <chema@berkeley.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33831 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab2IFGmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 02:42:19 -0400
Received: by bkwj10 with SMTP id j10so613026bkw.19
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2012 23:42:17 -0700 (PDT)
In-Reply-To: <CAEb0MffEfboq_VmPFCtzGHe-SQ4Dd1O6Hptrc_jHVnp7itKyQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 23:35 -0700, Chema Gonzalez wrote:
> From 5c02179069826bfba9360383b88601b31ff05517 Mon Sep 17 00:00:00 2001
> From: Chema Gonzalez <chema@google.com>
> Date: Wed, 5 Sep 2012 17:05:48 -0700
> Subject: [PATCH] net: Small bug on rxhash calculation
> 
> While the (current) sorting of the ports/addresses is coherent
> (you get the same rxhash for packets sharing the same (unsorted)
> 4-tuple), ports and addresses should not be sorted independently,
> which currently are: For traffic between A=S:l and B=L:s, packets
> in both directions would get their rxhash from hashing
> {L, S, {s, l}}. The same rxhash is obtained from packets between
> C=S:s and D=L:l.
> 
> This patch ensures traffic between A and B gets their rxhash
> from {S, L, {s, l}}, and traffic between C and D from {S, L,
> {l, s}}
> 
> The patch is co-written with Eric Dumazet <edumazet@google.com>
> 
> Signed-off-by: Chema Gonzalez <chema@google.com>
> ---

Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks !

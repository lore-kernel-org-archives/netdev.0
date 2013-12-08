From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet: fix NULL pointer Oops in fib(6)_rule_suppress
Date: Sun, 08 Dec 2013 11:28:36 -0800
Message-ID: <1386530916.30495.290.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131208191828.GS23153@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	daniel.golle@gmail.com, sergei.shtylyov@cogentembedded.com
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:35370 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305Ab3LHT2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 14:28:40 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so3996999pbb.8
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 11:28:39 -0800 (PST)
In-Reply-To: <20131208191828.GS23153@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-08 at 20:18 +0100, Stefan Tomanek wrote:
> Reported-by: Daniel Golle <daniel.golle@gmail.com>
> Tested-by: Daniel Golle <daniel.golle@gmail.com>
> Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
> ---
>  net/ipv4/fib_rules.c  |    5 ++++-
>  net/ipv6/fib6_rules.c |    6 +++++-
>  2 files changed, 9 insertions(+), 2 deletions(-)

Please add a changelog, and possibly the header like :

Fixes: 6ef94cfafba15 ("fib_rules: add route suppression based on ifgroup")

Thats absolutely needed to help us to backport the fix into stable kernels.

Thanks

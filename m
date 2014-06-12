From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] net_sched: drr: warn when qdisc is not work conserving
Date: Thu, 12 Jun 2014 18:03:08 +0200
Message-ID: <aa75d9b0-e643-4fbe-b2bd-1c85982752e0@email.android.com>
References: <1402511718-24203-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56896 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755968AbaFLQDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 12:03:18 -0400
In-Reply-To: <1402511718-24203-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11. Juni 2014 20:35:18 MESZ, Florian Westphal <fw@strlen.de> wrote:
>The DRR scheduler requires that items on the active list are work
>conserving, i.e. do not hold on to skbs for throttling purposes, etc.
>Attaching e.g. tbf renders DRR useless because all other classes on the
>active list are delayed as well.
>
>So, warn users that this configuration won't work as expected; we
>already do this in couple of other qdiscs, see e.g.

Why don't prevent this during configuration time in the first place? It doesn't work, a warning might trigger long after creating the broken configuration and will more likely go unnoticed.

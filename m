From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Sun, 10 May 2015 10:25:47 -0700
Message-ID: <1431278747.566.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org>
	 <1431277170-4618-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ast@plumgrid.com,
	jhs@mojatatu.com, daniel@iogearbox.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35063 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbbEJRZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 13:25:50 -0400
Received: by igbyr2 with SMTP id yr2so54073634igb.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 10:25:49 -0700 (PDT)
In-Reply-To: <1431277170-4618-3-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-05-10 at 18:59 +0200, Pablo Neira Ayuso wrote:

> On top of that, this special qdisc does not enqueue anything at all, so we can
> skip the enqueue indirection from qdisc_enqueue_root() which is doing things
> that we don't need.

Note that we can get rid of qdisc_enqueue_root() completely, as
net/sched/sch_netem.c does not need need it either.

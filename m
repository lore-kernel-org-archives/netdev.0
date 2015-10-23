From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/11] net: ipv4: hlen could be set as size_t
Date: Fri, 23 Oct 2015 06:51:11 -0700 (PDT)
Message-ID: <20151023.065111.918009116932115995.davem@davemloft.net>
References: <1445602236-24130-11-git-send-email-clabbe.montjoie@gmail.com>
	<20151023.060852.167547226456492975.davem@davemloft.net>
	<20151023132100.GA16922@Red>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbbJWNel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:34:41 -0400
In-Reply-To: <20151023132100.GA16922@Red>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Fri, 23 Oct 2015 15:21:00 +0200

> I have added all mailing list given by get_maintainer but this was done per patch with --to-cmd/--cc-cmd
> Does it is better to put all mailing list globally ?
> 
> For the (0/N) mail, I forgot to add a subject on it https://lkml.org/lkml/2015/10/23/219
> 
> I will fix all minor finding and resend a proper version.

Ask yourself the question: who will apply my patch series and to what tree will
they apply it.

If you cannot answer that question, you probably need to more properly split
up your patches into several patch series, one for each intended maintainer
and their respective tree.

It is impossible to review some subset of a patch series, if the whole series
isn't also available to read for the purposes of context.

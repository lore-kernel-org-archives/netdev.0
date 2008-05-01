From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] unify the macro get_u16 in the file tulip.h
Date: Wed, 30 Apr 2008 17:43:49 -0700
Message-ID: <1209602629.8601.6.camel@localhost>
References: <93C271C5-550E-406B-AE43-C83419EA0BC6@gmail.com>
	 <20080501001522.GB10542@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	gao changli <xiaosuo@gmail.com>
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1808 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbYEAAwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 20:52:16 -0400
In-Reply-To: <20080501001522.GB10542@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-04-30 at 18:15 -0600, Grant Grundler wrote:
> On Thu, May 01, 2008 at 01:34:38AM +0800, gao changli wrote:
> > Unify the macro get_u16 with le16_to_cpu.
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> Acked-by: Grant Grundler <grundler@parisc-linux.org>
> please apply.  Depends on other patches that define le16_to_cpu().

Wouldn't it be better to remove get_u16 altogether
and use le16_to_cpu or __le16_to_cpup directly?



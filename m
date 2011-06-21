From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Tue, 21 Jun 2011 15:58:16 -0700 (PDT)
Message-ID: <20110621.155816.1840729860084652508.davem@davemloft.net>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
	<4E0115B3.2030802@redhat.com>
	<20110621225645.GD16021@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, prarit@redhat.com, netdev@vger.kernel.org,
	agospoda@redhat.com, nhorman@redhat.com, lwoodman@redhat.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab1FUW6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 18:58:24 -0400
In-Reply-To: <20110621225645.GD16021@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 22 Jun 2011 00:56:45 +0200

> Flavio Leitner <fbl@redhat.com> wrote:
>> What about a whitelist of source MAC or IP addresses to accept the sysrq?
> 
> This is one of the reasons why I still think that
> xt_SYSREQ would be the better solution, you get all
> kinds of filtering features for free.
> 
> You could even use crazy things like '-m time' to restrict
> sysreq availability to working hours and whatnot.

Agreed.

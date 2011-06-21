From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 00:56:45 +0200
Message-ID: <20110621225645.GD16021@Chamillionaire.breakpoint.cc>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
 <4E0115B3.2030802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Prarit Bhargava <prarit@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:56867 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754940Ab1FUW4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 18:56:46 -0400
Content-Disposition: inline
In-Reply-To: <4E0115B3.2030802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flavio Leitner <fbl@redhat.com> wrote:
> What about a whitelist of source MAC or IP addresses to accept the sysrq?

This is one of the reasons why I still think that
xt_SYSREQ would be the better solution, you get all
kinds of filtering features for free.

You could even use crazy things like '-m time' to restrict
sysreq availability to working hours and whatnot.

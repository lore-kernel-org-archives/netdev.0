From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_cubic: enable TCP timestamps
Date: Tue, 08 Mar 2011 11:38:53 -0800 (PST)
Message-ID: <20110308.113853.115934120.davem@davemloft.net>
References: <20110308.105503.104060436.davem@davemloft.net>
	<AANLkTinT0eHbbELWDLxYyj0axpYt=GHnxLP8fMH-pWOs@mail.gmail.com>
	<20110308193602.GA14526@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sangtae.ha@gmail.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: lucas.nussbaum@loria.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36514
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752374Ab1CHTiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 14:38:15 -0500
In-Reply-To: <20110308193602.GA14526@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Date: Tue, 8 Mar 2011 20:36:02 +0100

> My other patch mitigates the performance problem by making it harder for
> Hystart to abort slow start. But after a few days working on this issue,
> I'm wondering whether Hystart shouldn't be completely rewritten to work
> on the usec values, or disabled by default.

I am of the opinion that Hystart, like TCP VEGAS, fundamentally cannot
work.

It's disabled in several major distributions because of the performance
problems you noticed, and this was on my own personal recommendation.

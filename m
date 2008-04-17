From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7 net-2.6.26] [TIPC]: Remove inlining of reference
 table locking routines
Date: Wed, 16 Apr 2008 18:12:21 -0700 (PDT)
Message-ID: <20080416.181221.88201322.davem@davemloft.net>
References: <1208288637-15304-2-git-send-email-allan.stephens@windriver.com>
	<20080415.190001.248179700.davem@davemloft.net>
	<29C1DC0826876849BDD9F1C67ABA294392B103@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765260AbYDQBMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 21:12:19 -0400
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA294392B103@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Stephens, Allan" <allan.stephens@windriver.com>
Date: Wed, 16 Apr 2008 07:06:21 -0700

> Does your preference for use of the "!ptr" style also apply to
> non-pointer variables?  (For example, do you also prefer to see
> "!count" rather than "count == 0"?)  I'm asking because I've
> received conflicting guidance in the past (not from you, of course),
> which gave me the impression that the "ptr == NULL" form was the way
> the Linux kernel gatekeepers wanted to see things done.

I'm mostly ambivalent about that particular case.

But if I had to choose I'd say use "== 0" because
that is an easy way to visually distinguish pointer
NULL checks vs. integer zero ones without having
to know or see the type of the variable.

From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: [PATCH 2.6.25.3 1/5] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 26 Jun 2008 14:25:00 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A3EE603B8A3@SHEXMB-01.global.atheros.com>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE603B863@SHEXMB-01.global.atheros.com>
 <20080625224829.3c6f4789@extreme>
 <20080625.225550.199765051.davem@davemloft.net>
 <20080626055907.GD1369@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.210.DSNET ([203.110.175.210]:38243 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752272AbYFZGZd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 02:25:33 -0400
In-Reply-To: <20080626055907.GD1369@1wt.eu>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau [w@1wt.eu]
Date: Thursday, June 26, 2008 1:59 PM

> On Wed, Jun 25, 2008 at 10:55:50PM -0700, David Miller wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Wed, 25 Jun 2008 22:48:29 -0700
> >
> > > I would prefer that the driver be NAPI only, because
> configuration
> > > choices are hard for users and distribution to make
> correct choice.
> > > Plus it means two choices for your QA to test.
> >
> > I agree with Stephen.
> >
> > It's absolutely to provide a non-NAPI option, please just
> remove the
> > option and the conditionals from the code.
>
> Also I think it's useless to provide one patch per source
> file. It'd be better to have one whole patch, or several ones
> if some features may be added incrementally.
>
> Willy
>
>

Ok, thanks for comments. I will change code on these comments.

jie

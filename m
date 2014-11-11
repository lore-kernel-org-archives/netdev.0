From: Joe Perches <joe@perches.com>
Subject: Re: am335x: cpsw: phy ignores max-speed setting
Date: Tue, 11 Nov 2014 11:08:46 -0800
Message-ID: <1415732926.16070.9.camel@perches.com>
References: <CAGm1_ktWK5ai85PZJTkq8Q1mAFH6JZ5XM1mDOHO3K_N2iGNLWg@mail.gmail.com>
	 <CAA93jw5=LDirktyC+rvpLi-kywUSosj6QV8-na5p3-f=PxKcWQ@mail.gmail.com>
	 <1415301589.6634.63.camel@perches.com>
	 <CAA93jw7PTOGdYrmFGSY5zat=MpVsdmESVwpK_tVO=sLeDSWpRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mugunthan N V <mugunthanvnm@ti.com>, mpa@pengutronix.de,
	lsorense@csclub.uwaterloo.ca,
	Yegor Yefremov <yegorslists@googlemail.com>,
	Daniel Mack <zonque@gmail.com>, netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0099.hostedemail.com ([216.40.44.99]:47995 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750859AbaKKTIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 14:08:51 -0500
In-Reply-To: <CAA93jw7PTOGdYrmFGSY5zat=MpVsdmESVwpK_tVO=sLeDSWpRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-11 at 10:44 -0800, Dave Taht wrote:
> On Nov 6, 2014 11:19 AM, "Joe Perches" <joe@perches.com> wrote:
[]
> > Is this the change that matters most?
> >
> > -#define CPSW_POLL_WEIGHT       64
> > +#define CPSW_POLL_WEIGHT       16
[]
> > If so, maybe this could be limited by a sysctl:
[]
> I'd like autotuning for the underlying rate somehow....

That might be difficult to achieve with variable rates.

From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC 0/2] Control VF link state
Date: Fri, 10 May 2013 02:17:33 +0300
Message-ID: <CAJZOPZJ052r67==xXciyoTmE8TQwXyx5sVgeuR=dQUEpXkd5WQ@mail.gmail.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	<1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	amirv@mellanox.com, ronye@mellanox.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:44711 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468Ab3EIXRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 19:17:34 -0400
Received: by mail-qa0-f41.google.com with SMTP id bv4so53854qab.7
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 16:17:33 -0700 (PDT)
In-Reply-To: <1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 9, 2013 at 6:24 PM, Ben Hutchings <bhutchings@solarflare.com> wrote:
>
> On Wed, 2013-05-08 at 16:45 +0300, Or Gerlitz wrote:
> > Here's a suggestion for API and implementation that lets the admin to
> > configure
> > the link state of the VF / SRIOV eSwitch vPORT. Basically, it has three
> > states
> >
> > Auto -        the VF link state will reflect the PF link state
> >
> > Enable - VF link stat will be always up, traffic from VF to VF can
> >        work even if PF link is down.
>
> It seems like it would be useful to implement these two options on the PF as well.

You mean that PF <--> VF communication on the same node can be made to
work even when the physical link is down? this is a bit problematic to
model/implement I think. Generally speaking it makes things easier to
grasp if PF is considered to be the uplink of the eSwitch whos link is
1:1 as the physical link, but need to think that a bit more.


> Perhaps the default should also be specified?

mmm, not sure if we can require/enforce the same default for all drivers.

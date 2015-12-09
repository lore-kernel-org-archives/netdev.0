From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Checksum offload queries
Date: Wed, 9 Dec 2015 23:21:53 +0100
Message-ID: <20151209222153.GE11201@pox.localdomain>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
 <5666EC4B.40800@solarflare.com>
 <20151208.120654.2127200076257822677.davem@davemloft.net>
 <56681B18.3030200@solarflare.com>
 <CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
 <566864C0.6020204@solarflare.com>
 <CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33727 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbLIWVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:21:55 -0500
Received: by mail-wm0-f44.google.com with SMTP id c201so6478694wme.0
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 14:21:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/15 at 10:00am, Tom Herbert wrote:
> On Wed, Dec 9, 2015 at 9:28 AM, Edward Cree <ecree@solarflare.com> wrote:
> > Which only pushes the problem onto when someone wants to nest
> > encapsulations.  (I heard you like tunnels, so I put a tunnel in your
> > tunnel so you can encapsulate while you encapsulate.)
> > Or to put it another way, 2 isn't a number; the only numbers are 0, 1
> > and infinity ;)
> > Perhaps in practice 2 csums would be enough, for now.  But isn't the
> > whole point of the brave new world of generic checksums that it should
> > be future-proof?
> >
> If there is a need then we can add an arbitrary number. But no one has
> proven there is a need, however we do have a real need for checksum
> offload outside of the narrow uses of  NETIF_F_IP[V6]_CSUM.

Need may be a strong word here but people have started doing nested
tunneling by running container orchestration tools which use VXLAN
to isolate containers inside of OpenStack virtual infrastructure which
also creates virtual networks.

I'm not saying it's sane or desirable but we will start seeing nested
tunnels in the wild :-(

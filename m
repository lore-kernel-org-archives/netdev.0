From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [Patch] Fix commit
 63d9950b08184e6531adceb65f64b429909cc101 (ipv6: Make v4-mapped bindings
 consistent with IPv4)
Date: Thu, 3 Sep 2009 15:25:21 -0700
Message-ID: <20090903222521.GD23517@kroah.com>
References: <20090822011541.7b95dbcc@neptune.home>
 <20090822014523.3ec2f591@neptune.home>
 <20090823.190715.124304781.davem@davemloft.net>
 <20090825222042.4d13aacd@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable@kernel.org, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:41655 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932370AbZICW1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 18:27:31 -0400
Content-Disposition: inline
In-Reply-To: <20090825222042.4d13aacd@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2009 at 10:20:42PM +0200, Bruno Pr=E9mont wrote:
> On Sun, 23 August 2009 David Miller <davem@davemloft.net> wrote:
> > From: Bruno Pr=E9mont <bonbons@linux-vserver.org>
> > Date: Sat, 22 Aug 2009 01:45:23 +0200
> >=20
> > > Commit 63d9950b08184e6531adceb65f64b429909cc101
> > >   (ipv6: Make v4-mapped bindings consistent with IPv4)
> > > changes behavior of inet6_bind() for v4-mapped addresses so it
> > > should behave the same way as inet_bind().
> > >=20
> > > During this change setting of err to -EADDRNOTAVAIL got lost:
> >  ...
> > > Signed-off-by Bruno Pr=E9mont <bonbons@linux-vserver.org>
> >=20
> > Thanks for finding and fixing this bug, applied, thanks!
>=20
> Please consider queueing this for 2.6.30.x stable, upstream commit is
> ca6982b858e1d08010c1d29d8e8255b2ac2ad70a

Now queued up.

thanks,

greg k-h

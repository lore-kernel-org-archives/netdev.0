From: =?ISO-8859-1?Q?S=E9bastien_Dugu=E9?= <sebastien.dugue@bull.net>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Fri, 28 Jul 2006 09:26:50 +0200
Message-ID: <1154071610.13577.2.camel@frecb000686>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru>
	 <20060726100431.GA7518@infradead.org> <20060726101919.GB2715@2ka.mipt.ru>
	 <20060726103001.GA10139@infradead.org> <44C77C23.7000803@redhat.com>
	 <44C796C3.9030404@us.ibm.com> <1153982954.3887.9.camel@frecb000686>
	 <44C8DB80.6030007@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Suparna Bhattacharya <suparna@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:4280 "EHLO
	ecfrec.frec.bull.fr") by vger.kernel.org with ESMTP id S932586AbWG1H1C convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 03:27:02 -0400
To: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <44C8DB80.6030007@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-07-27 at 08:28 -0700, Badari Pulavarty wrote:
> S=E9bastien Dugu=E9 wrote:
> > On Wed, 2006-07-26 at 09:22 -0700, Badari Pulavarty wrote:
> >  =20
> >> Ulrich Drepper wrote:
> >>    =20
> >>> Christoph Hellwig wrote:
> >>>  =20
> >>>      =20
> >>>>> My personal opinion on existing AIO is that it is not the right=
 design.
> >>>>> Benjamin LaHaise agree with me (if I understood him right),
> >>>>>      =20
> >>>>>          =20
> >>>> I completely agree with that aswell.
> >>>>    =20
> >>>>        =20
> >>> I agree, too, but the current code is not the last of the line.  =
Suparna
> >>> has a st of patches which make the current kernel aio code work m=
uch
> >>> better and especially make it really usable to implement POSIX AI=
O.
> >>>
> >>> In Ottawa we were talking about submitting it and Suparna will.  =
We just
> >>> thought about a little longer timeframe.  I guess it could be
> >>> accelerated since he mostly has the patch done.  But I don't know=
 her
> >>> schedule.
> >>>
> >>> Important here is, don't base any decision on the current aio
> >>> implementation.
> >>>  =20
> >>>      =20
> >> Ulrich,
> >>
> >> Suparna mentioned your interest in making POSIX glibc aio work wit=
h=20
> >> kernel-aio at OLS.
> >> We thought taking a re-look at the (kernel side) work BULL did, wo=
uld be=20
> >> a nice starting
> >> point. I re-based those patches to 2.6.18-rc2 and sent it to Zach =
Brown=20
> >> for review before
> >> sending them out to list.
> >>
> >> These patches does NOT make AIO any cleaner. All they do is add=20
> >> functionality to support
> >> POSIX AIO easier. These are
> >>
> >> [ PATCH 1/3 ]  Adding signal notification for event completion
> >>
> >> [ PATCH 2/3 ]  lio (listio) completion semantics
> >>
> >> [ PATCH 3/3 ] cancel_fd support
> >>    =20
> >
> >   Badari,
> >
> >   Thanks for refreshing those patches, they have been sitting here
> > for quite some time now and collected dust.
> >
> >   I also think Suparna's patchset for doing buffered AIO would be
> > a real plus here.
> >
> >  =20
> >> Suparna explained these in the following article:
> >>
> >> http://lwn.net/Articles/148755/
> >>
> >> If you think, this is a reasonable direction/approach for the kern=
el and=20
> >> you would take care
> >> of glibc side of things - I can spend time on these patches, getti=
ng=20
> >> them to reasonable shape
> >> and push for inclusion.
> >>    =20
> >
> >   Ulrich, I you want to have a look at how those patches are put to
> > use in libposix-aio, have a look at http://sourceforge.net/projects=
/paiol.
> >
> >   It could be a starting point for glibc.
> >
> >   Thanks,
> >
> >   S=E9bastien.
> >
> >  =20
> Sebastien,
>=20
> Suparna mentioned at Ulrich wants us to concentrate on kernel-side=20
> support, so that he
> can look at glibc side of things (along with other work he is already=
=20
> doing). So, if we
> can get an agreement on what kind of kernel support is needed - we ca=
n=20
> focus our
> efforts on kernel side first and leave glibc enablement to capable ha=
nds=20
> of Uli :)
>=20

  That's fine with me.=20

  S=E9bastien.

--=20
-----------------------------------------------------

  S=E9bastien Dugu=E9                BULL/FREC:B1-247
  phone: (+33) 476 29 77 70      Bullcom: 229-7770

  mailto:sebastien.dugue@bull.net

  Linux POSIX AIO: http://www.bullopensource.org/posix
                   http://sourceforge.net/projects/paiol

-----------------------------------------------------


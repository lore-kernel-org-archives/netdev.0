From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 15:49:30 +0300
Message-ID: <200907201549.30870.remi.denis-courmont@nokia.com>
References: <200907201247.23020.remi.denis-courmont@nokia.com> <20090720.034328.193709571.davem@davemloft.net> <1248091650.4549.107.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:48302 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbZGTMsh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 08:48:37 -0400
Received: from vaebh106.NOE.Nokia.com (vaebh106.europe.nokia.com [10.160.244.32])
	by mgw-mx03.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6KCm9Qn010386
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 15:48:29 +0300
Received: from leon.remlab.net (esdhcp03592.research.nokia.com [172.21.35.92])
	by mgw-sa02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6KCl8m1018706
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 15:47:08 +0300
In-Reply-To: <1248091650.4549.107.camel@violet>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 20 July 2009 15:07:30 ext Marcel Holtmann wrote:
> Hi Dave,
>
> > > On Monday 20 July 2009 13:21:01 ext Marcel Holtmann wrote:
> > >> > It's just like most network protocols exposing their sockets l=
ist in
> > >> > /proc/net. Debugging/monitoring indeed.
> > >>
> > >> I think that for new protocols, we should not do this anymore an=
d just
> > >> use debugfs. Since that is exactly its job.
> > >
> > > Requiring debugfs for something like 'netstat' sounds restrictive=
 to
> > > me...
> >
> > Me too.
>
> hold on, what has netstat to do with Phonet support?

=46irst, I said "*like* netstat". Second, *net*stat has at least as muc=
h to do=20
with Pho*net* than it has with Unix sockets. I'm interested in monitori=
ng=20
userland usage of Phonet sockets, not so much in debugging the kernel-m=
ode=20
Phonet stack. I am not convinced that debugfs is the right tool at all =
here -=20
regardless whether we extend netstat or write a Phonet-specific tool.

> Does netstat now support Phonet or what are we trying to achieve here=
?

There is currently no Phonet socket monitoring hook. I guess you refer =
to=20
backward compatibility, which -I would agree- is a non-issue.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki


From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH 2/2] net caif:  Register properly as a pernet subsystem.
Date: Fri, 27 Jan 2012 15:48:00 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C105791FB48AD1FB@EXDCVYMBSTM005.EQ1STM.local>
References: <4F212E7E.2040801@parallels.com>
	 <1327575108.2500.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <m1zkdacbsx.fsf@fess.ebiederm.org>
	 <20120126.180754.679593869814492219.davem@davemloft.net>
	 <m1ehumc8r4.fsf_-_@fess.ebiederm.org> <m1aa5ac8nu.fsf_-_@fess.ebiederm.org>
 <1327670668.14789.4.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"xemul@parallels.com" <xemul@parallels.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davej@redhat.com" <davej@redhat.com>,
	"sjurbren@gmail.com" <sjurbren@gmail.com>
To: Sasha Levin <levinsasha928@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:39473 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752017Ab2A0Osr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jan 2012 09:48:47 -0500
In-Reply-To: <1327670668.14789.4.camel@lappy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > caif is a subsystem and as such it needs to register with
> > register_pernet_subsys instead of register_pernet_device.
> >
> > Among other problems using register_pernet_device was resulting in
> > net_generic being called before the caif_net structure was allocate=
d.
> > Which has been causing net_generic to fail with either BUG_ON's or =
by
> > return NULL pointers.
> >
> > A more ugly problem that could be caused is packets in flight why t=
he
> > subsystem is shutting down.
> >
> > To remove confusion also remove the cruft cause by inappropriately
> > trying to fix this bug.
> >
> > With the aid of the previous patch I have tested this patch and
> > confirmed that using register_pernet_subsys makes the failure go aw=
ay
> > as it should.
> >
> > Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>=20
> I've tested these two patches as well, and they also work for me.
>=20
> 	Tested-by: Sasha Levin <levinsasha928@gmail.com>

This looks very good to me, thank you Eric.=20

Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] sky2: Reading registers in reset causes a hang
Date: Tue, 13 Oct 2009 09:00:38 -0700
Message-ID: <20091013090038.6ec27475@nehalam>
References: <4AD337ED.4090409@ring3k.org>
	<20091012091459.49eb1188@nehalam>
	<392fb48f0910121536x3e7c37fbjd83ef821b3617644@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44421 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760433AbZJMQBU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 12:01:20 -0400
In-Reply-To: <392fb48f0910121536x3e7c37fbjd83ef821b3617644@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Oct 2009 07:36:45 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> 2009/10/13 Stephen Hemminger <shemminger@linux-foundation.org>
> >
> > On Mon, 12 Oct 2009 23:06:37 +0900
> > Mike McCormack <mikem@ring3k.org> wrote:
> >
> > > When sky2 hardware is in reset, reading registers with ethtool -d
> > > causes a hard system hang. eg.
> > >
> > > =C2=A0 =C2=A0 ifconfig eth1 down
> > > =C2=A0 =C2=A0 ethtool -d eth1
> > >
> > > Avoid reading FIFOs, descriptor and status unit, etc. after we've
> > > =C2=A0bought the interface down, as these seem to cause the issue=
=2E
> > >
> > > Assume the same is true for the second port, as my port only has
> > > =C2=A0one card.
> >
> > I don't see this on my cards. Let me investigate further before
> > committing this. Also, the debugfs interface would also be screwed
> > if the registers were unavailable.
>=20
> I forgot to include one other piece of information... I'm running a
> ping -f at the sky2 interface on a remote machine. I'll check debugfs
> tonight.
>=20

You are flooding a down interface??
--=20

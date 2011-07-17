From: David Lamparter <equinox@diac24.net>
Subject: Re: recommended way to support duplicate IP addresses on different
 VLANs?
Date: Sun, 17 Jul 2011 17:21:12 +0200
Message-ID: <20110717152112.GF1407585@jupiter.n2.diac24.net>
References: <4E1B0F86.2040508@mail.usask.ca>
 <201107111804.26500.remi@remlab.net>
 <m1tyankr6x.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?UsOpbWk=?= Denis-Courmont <remi@remlab.net>,
	Chris Friesen <cbf123@mail.usask.ca>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:54735 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab1GQPVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 11:21:24 -0400
Content-Disposition: inline
In-Reply-To: <m1tyankr6x.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2011 at 05:24:54PM -0700, Eric W. Biederman wrote:
> "R=C3=A9mi Denis-Courmont" <remi@remlab.net> writes:
> > Namespace file descriptors if/when they get accepted.
>=20
> For reference.
>=20
> The namespace file descriptor code is in 3.0.  setns is present in th=
e
> latest glibc.  And the iproute support is just finishing up.
>=20
> What doesn't exist at the moment is a handy socketat library
> function to make it a userspace program that uses multiple network
> namespaces trivial.  But that is only a few lines of code.

A few lines of code that can be found at
http://git.spaceboyz.net/equinox/vrf-tools.git/

pptpd already supports it, an OpenVPN patch is in the repo.

I'm updating it to match the paths used by "ip netns" over the next
few days.


-David

P.S.: Eric, there is no way to recognise a namespace descriptor as
such from userspace, other than trying setns()?

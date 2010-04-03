From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 0/6] tagged sysfs support
Date: Sat, 03 Apr 2010 01:58:23 +0100
Message-ID: <1270256303.12516.234.camel@localhost>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	 <ac3eb2511003301153i43a60720hb015071e2c992199@mail.gmail.com>
	 <m14ojxh0mz.fsf@fess.ebiederm.org>
	 <s2hac3eb2511003302251rcbae8767ne21e9daf1546c849@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-PlT9U4DmwiuG74DiJlKJ"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52820 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754465Ab0DCA7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 20:59:00 -0400
In-Reply-To: <s2hac3eb2511003302251rcbae8767ne21e9daf1546c849@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PlT9U4DmwiuG74DiJlKJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-03-31 at 07:51 +0200, Kay Sievers wrote:
> On Wed, Mar 31, 2010 at 01:04, Eric W. Biederman <ebiederm@xmission.com> =
wrote:
> > Kay Sievers <kay.sievers@vrfy.org> writes:
> >> On Tue, Mar 30, 2010 at 20:30, Eric W. Biederman <ebiederm@xmission.co=
m> wrote:
> >>>
> >>> The main short coming of using multiple network namespaces today
> >>> is that only network devices for the primary network namespaces
> >>> can be put in the kobject layer and sysfs.
> >>>
> >>> This is essentially the earlier version of this patchset that was
> >>> reviewed before, just now on top of a version of sysfs that doesn't
> >>> need cleanup patches to support it.
> >>
> >> Just to check if we are not in conflict with planned changes, and how
> >> to possibly handle them:
> >>
> >> There is the plan and ongoing work to unify classes and buses, export
> >> them at /sys/subsystem in the same layout of the current /sys/bus/.
> >> The decision to export buses and classes as two different things
> >> (which they aren't) is the last major piece in the sysfs layout which
> >> needs to be fixed.
> >
> > Interesting.  We will symlinks ie:
> > /sys/class -> /sys/subsystem
> > /sys/bus -> /sys/subsystem
> > to keep from breaking userspace.
>=20
> Yeah, /sys/bus/, which is the only sane layout of the needlessly
> different 3 versions of the same thing (bus, class, block).
[...]

block vs class/block is arguable, but as for abstracting the difference
between bus and class... why?

Each bus defines a device interface covering enumeration,
identification, power management and various aspects of their connection
to the host.  This interface is implemented by the bus driver.

Each class defines a device interface covering functionality provided to
user-space or higher level kernel components (block interface to
filesystems, net driver interface to the networking core, etc).  This
interface is implemented by multiple device-specific drivers.

So while buses and classes both define device interfaces, they are
fundamentally different types of interface.  And there are 'subsystems'
that don't have devices at all (time, RCU, perf, ...).  If you're going
to expose the set of subsystems, don't they belong in there?  But then,
what would you put in their directories?

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-PlT9U4DmwiuG74DiJlKJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS7aSq+e/yOyVhhEJAQJEZw/+OU6TO5XXg6e81XOoC6dxgh25Z6gC5Rvu
VbW1+7wK/NVALQLcQCIPVB8FHJZPcr1I10qJgnL2TuO5NHfIXWZL9WRznXTceyJO
Sq6BrhFM+KDmNDvt+UPESMJ4u6FOpWq5Bgi0dGi3I82aTdV1pL/Ojm0mAIHUv8wr
UokeX1Ja8NgME+f4ur73utSeOVQAMLpQI0UiXN/mtzv2fhaHc8JG2FzeUNoJ9ZyL
KPyxvP2H9a5Lu18O5Bkf3sqMOh6A5RVyQ02jLZlih2smzBcSZ3MSQGjZrwA9hP2+
Cjd1yuD4OhB3iY/7MMbxSfoOnAI7z8hb+hsWQOfek4o7hIWVXLpe7Q8QqZfE8xUC
TATNTK6BliwW4hYqyDZu8bV2lHZz3L5su9Bph2bWudy1QGBsXUV6BT3PiKcD05hn
EReoW8UU6QOMRnEZBHOjjVdoIzklGd5Z344B/yw23Sgouf79G0kAq5PqWGCJTDit
XjNUNJtO0FZONnBSk7FbhutcBzIqIxpVxn3dXDKdkjDLix0EZ+1hK0ooZtumu6zL
bWyXP/1keX+Avh8cxmjd+ovavxjDj2vvnr1JfaWAIKQ3IS8xAgRqh6GihrPgd0as
yST3Bd0TTKYcWQASBcq2PRK5GSTIB6vQdXgB7fOgXIe+RhEtOaPAzOCwHgCR+5TU
fodLL/0h/zE=
=u6dY
-----END PGP SIGNATURE-----

--=-PlT9U4DmwiuG74DiJlKJ--

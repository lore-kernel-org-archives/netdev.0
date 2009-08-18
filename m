From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Tue, 18 Aug 2009 11:51:59 -0400
Message-ID: <4A8ACE1F.6020402@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig742C65808FA9E8BC21F82393"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8AB076.6080906@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig742C65808FA9E8BC21F82393
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/18/2009 04:16 PM, Gregory Haskins wrote:
>> The issue here is that vbus is designed to be a generic solution to
>> in-kernel virtual-IO.  It will support (via abstraction of key
>> subsystems) a variety of environments that may or may not be similar i=
n
>> facilities to KVM, and therefore it represents the
>> least-common-denominator as far as what external dependencies it
>> requires.
>>   =20
>=20
> Maybe it will be easier to evaluate it in the context of these other
> environments.  It's difficult to assess this without an example.

When they are ready, I will cross post the announcement to KVM.

>=20
>> The bottom line is this: despite the tendency for people to jump at
>> "don't put much in the kernel!", the fact is that a "bus" designed for=

>> software to software (such as vbus) is almost laughably trivial.  Its
>> essentially a list of objects that have an int (dev-id) and char*
>> (dev-type) attribute.  All the extra goo that you see me setting up in=

>> something like the kvm-connector needs to be done for fast-path
>> _anyway_, so transporting the verbs to query this simple list is not
>> really a big deal.
>>   =20
>=20
> It's not laughably trivial when you try to support the full feature set=

> of kvm (for example, live migration will require dirty memory tracking,=

> and exporting all state stored in the kernel to userspace).

Doesn't vhost suffer from the same issue?  If not, could I also apply
the same technique to support live-migration in vbus?

>=20
>> Note that I didn't really want to go that route.  As you know, I tried=

>> pushing this straight through kvm first since earlier this year, but I=

>> was met with reluctance to even bother truly understanding what I was
>> proposing, comments like "tell me your ideas so I can steal them", and=

>>   =20
>=20
> Oh come on, I wrote "steal" as a convenient shorthand for
> "cross-pollinate your ideas into our code according to the letter and
> spirit of the GNU General Public License".

Is that supposed to make me feel better about working with you?  I mean,
writing, testing, polishing patches for LKML-type submission is time
consuming.  If all you are going to do is take those ideas and rewrite
it yourself, why should I go through that effort?

And its not like that was the first time you have said that to me.

> Since we're all trying to improve Linux we may as well cooperate.

Well, I don't think anyone can say that I haven't been trying.

>=20
>> "sorry, we are going to reinvent our own instead".
>=20
> No.  Adopting venet/vbus would mean reinventing something that already
> existed.

But yet, it doesn't.


>  Continuing to support virtio/pci is not reinventing anything.

No one asked you to do otherwise.

>=20
>> This isn't exactly
>> going to motivate someone to continue pushing these ideas within that
>> community.  I was made to feel (purposely?) unwelcome at times.  So I
>> can either roll over and die, or start my own project.
>>   =20
>=20
> You haven't convinced me that your ideas are worth the effort of
> abandoning virtio/pci or maintaining both venet/vbus and virtio/pci.

With all due respect, I didnt ask you do to anything, especially not
abandon something you are happy with.

All I did was push guest drivers to LKML.  The code in question is
independent of KVM, and its proven to improve the experience of using
Linux as a platform.  There are people interested in using them (by
virtue of the number of people that have signed up for the AlacrityVM
list, and have mailed me privately about this work).

So where is the problem here?


> I'm sorry if that made you feel unwelcome.  There's no reason to
> interpret disagreement as malice though.
>=20

Ok.

Kind Regards,
-Greg



--------------enig742C65808FA9E8BC21F82393
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqKzh8ACgkQP5K2CMvXmqEAyQCfUyOnz95kB7w7+t1RGVP8GZ0c
aJAAn1jKoyRXSoJXn90qqOX2GKMrqz3S
=/8fc
-----END PGP SIGNATURE-----

--------------enig742C65808FA9E8BC21F82393--

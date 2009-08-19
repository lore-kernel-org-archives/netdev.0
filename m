From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for		 vbus_driver
 objects
Date: Wed, 19 Aug 2009 07:52:05 -0400
Message-ID: <4A8BE765.4080507@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818165139.GC19846@redhat.com> <4A8B8F4E.80207@gmail.com> <4A8B9241.20300@redhat.com> <4A8B66280200005A00052A54@sinclair.provo.novell.com> <4A8BA635.9010902@redhat.com> <4A8BAC750200005A00052A83@sinclair.provo.novell.com> <4A8BE6D2.3090107@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF390A7EA939086EFC21A099B"
Cc: Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	alacrityvm-devel@lists.sourceforge.net,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8BE6D2.3090107@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF390A7EA939086EFC21A099B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/19/2009 02:40 PM, Gregory Haskins wrote:
>>
>>>>>> So if I whip up a virtio-net backend for vbus with a PCI compliant=

>>>>>> connector, you are happy?
>>>>>>
>>>>>>
>>>>>>           =20
>>>>> This doesn't improve virtio-net in any way.
>>>>>
>>>>>         =20
>>>> Any why not?  (Did you notice I said "PCI compliant", i.e. over
>>>> virtio-pci)
>>>>
>>>>       =20
>>> Because virtio-net will have gained nothing that it didn't have befor=
e.
>>>     =20
>> ??
>>
>> *) ABI is virtio-pci compatible, as you like
>>   =20
>=20
> That's not a gain, that's staying in the same place.
>=20
>> *) fast-path is in-kernel, as we all like
>>   =20
>=20
> That's not a gain as we have vhost-net (sure, in development, but your
> proposed backend isn't even there yet).
>=20
>> *) model is in vbus so it would work in all environments that vbus
>> supports.
>>   =20
>=20
> The ABI can be virtio-pci compatible or it can be vbus-comaptible.  How=

> can it be both?  The ABIs are different.
>=20
> Note that if you had submitted a virtio-net backend I'd have asked you
> to strip away all the management / bus layers and we'd have ended up
> with vhost-net.

Sigh...


>=20
>>>>> virtio already supports this model; see lguest and s390.  Transport=
ing
>>>>> virtio over vbus and vbus over something else doesn't gain anything=

>>>>> over
>>>>> directly transporting virtio over that something else.
>>>>>
>>>>>         =20
>>>> This is not what I am advocating.
>>>>
>>>>
>>>>       =20
>>> What are you advocating?  As far as I can tell your virtio-vbus
>>> connector plus the vbus-kvm connector is just that.
>>>     =20
>> I wouldn't classify it anything like that, no.  Its just virtio over
>> vbus.
>>   =20
>=20
> We're in a loop.  Doesn't virtio over vbus need a virtio-vbus
> connector?  and doesn't vbus need a connector to talk to the hypervisor=
?
>=20

No, it doesnt work like that.  There is only one connector.

Kind Regards,
-Greg


--------------enigF390A7EA939086EFC21A099B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqL52UACgkQP5K2CMvXmqHY7ACeNb1WRGNNTqFwpafFKn+V4aJE
8o8An1peelxo6QgsHVpBDaaSWJrtUsFg
=fs0D
-----END PGP SIGNATURE-----

--------------enigF390A7EA939086EFC21A099B--

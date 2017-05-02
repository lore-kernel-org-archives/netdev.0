From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Tue, 2 May 2017 10:34:18 -0400
Message-ID: <e37b9968-39da-8621-c509-2160810c390f@redhat.com>
References: <20170501163311.GA22209@lst.de>
 <1493659776.2665.7.camel@sandisk.com>
 <dce14470-06f4-8da3-6894-cd724eac3447@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="H2GFNbTh18venRakI8gtu0aQPhJfrKgEx"
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <dce14470-06f4-8da3-6894-cd724eac3447-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--H2GFNbTh18venRakI8gtu0aQPhJfrKgEx
Content-Type: multipart/mixed; boundary="WOW2lBcncRtnPwncuvQBuCe7iqBXFo36a";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
 Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>, "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
 "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Message-ID: <e37b9968-39da-8621-c509-2160810c390f-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: net/smc and the RDMA core
References: <20170501163311.GA22209-jcswGhMUV9g@public.gmane.org>
 <1493659776.2665.7.camel-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
 <dce14470-06f4-8da3-6894-cd724eac3447-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
In-Reply-To: <dce14470-06f4-8da3-6894-cd724eac3447-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

--WOW2lBcncRtnPwncuvQBuCe7iqBXFo36a
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 5/2/2017 8:34 AM, Ursula Braun wrote:
> On 05/01/2017 07:29 PM, Bart Van Assche wrote:
>> On Mon, 2017-05-01 at 18:33 +0200, Christoph Hellwig wrote:
>>> Hi Ursual, hi netdev reviewers,
>>>
>>> how did the smc protocol manage to get merged without any review=20
>>> on linux-rdma at all?  As the results it seems it's very substandard
>>> in terms of RDMA API usage, e.g. it neither uses the proper CQ API
>>> nor the RDMA R/W API, and other will probably find additional issues
>>> as well.
>>
>> Hello Dave and Ursula,
>>
>> It seems very rude to me to have merged the SMC protocol driver withou=
t
>> having involved the linux-rdma community. Anyway, I have the following=

>> questions for Dave and Ursula:
>> * Since the Linux kernel is standards based: where can we find the sta=
ndard
>>   that defines the SMC wire protocol? If this protocol has not been
>>   standardized yet: in what file (other than *.[ch]) in the Linux kern=
el
>>   tree has this protocol been documented?
>=20
> Hello Bart,
>=20
> The protocol is standardized, see: http://www.rfc-editor.org/info/rfc76=
09.

No, SMC-R is *not* standardized.  It is informationally publicized.  In
other words, you guys dumped what you considered your standard out and
rfc-editor published it under the "information" status category.  To be
an Internet Standard requires more work, and additionally requires a
period of time for people to comment on this proposal.  Given that this
is for a linux RDMA communications layer, advertising this RFC on the
linux-rdma@ mailing list seems the absolute *minimum* advertising that
should be done during the comment phase (at least as relates to the RDMA
portion of this protocol, which this protocol is first and foremost an
RDMA protocol with only TCP as a control/fallback).  It's been 18 months
since you published this, and this is the first that it's been brought
to the linux-rdma@ mailing list to my knowledge.

Anyway, the RFC is informational, not a standard, and as it stands, I'm
pretty sure the RDMA community would have a number of comments on it
before it were allowed to become a standard, including the fact that it
is currently exclusive to RoCEv1 which is, as far as the RDMA community
is concerned, a deprecated RoCE mode.  Adding a new protocol that only
supports this is just simply short sighted.  Had we been consulted
before this was merged, I have no doubt that we would have had a
considerable list of review requirements.  But, we are where we are, so
the issue is how to move forward.  Moving it to staging doesn't seem so
inappropriate in this particular case...

> I described this and some more protocol details in my patch series
> overview mail, see for instance:
>      http://marc.info/?l=3Dlinux-s390&m=3D148397751211964&w=3D2
>=20
> This description explains the reasons to come up with SMC-R.
>=20
>> * What are the differences between the SMC protocol, the SDP protocol =
and
>>   the rsockets protocol? How do existing implementations for these pro=
tocols
>>   compare to each other from a performance point of view? If no perfor=
mance
>>   comparison between these protocols is available, shouldn't the perfo=
rmance
>>   of these protocols have been compared with each other before a revie=
w of
>>   the SMC driver even started?
>> * What are the reasons why the SDP driver was never accepted upstream?=
 Do
>>   the arguments why SDP was not accepted upstream also apply to the SM=
C
>>   driver (SDP =3D Sockets Direct Protocol)?
>> * Since SMC has to be selected by specifying AF_SMC, how are users exp=
ected
>>   to specify whether AF_INET, AF_INET6 or yet another address family s=
hould
>>   be used to set up a connection between SMC
>> endpoints?
>=20
> The IPv6 support in SMC-R is on our todo-list.
>=20
>> * Is the SMC driver limited to RoCE? Are you aware that the rsockets l=
ibrary
>>   supports multiple transport layers (RoCE, IB and iWARP)?
>=20
> For now, only RoCE is supported. Other transports might be added in the=
 future.

We generally don't allow this type of partial support in RDMA code if we
can avoid it.  There are means in place in the RDMA subsystem to hide
the differences between the different RDMA types and we highly frown on
any code that doesn't deal with all of the fabrics.  Old code might get
grandfathered in if it had good reason for being specific to a fabric,
but not new code.  Fixing this would have been high on our list of
review items.  At a minimum supporting iWARP and all flavors of RoCE
would have required as these are all Ethernet devices at their heart and
should all support the required TCP control channel and such.  We
*might* have been more lenient on IB and OPA since they don't have a
native TCP network device, but since IPoIB works on both, even that
isn't really a reason not to support them.  The real issue is the much
more difficult issue of namespaces and SELinux, which is different
between TCP sockets and IB/OPA connections.  That would have been the
difficult part to get right, but as we haven't investigated it, we
really don't know if it would have been solvable in a reasonable fashion.=


>> * Since functionality that is similar what the SMC driver provides alr=
eady
>>   exists in user space (rsockets), why has this functionality been
>>   reimplemented as a kernel driver (SMC)?
>>
>> Bart.
>>
>=20
> Regards, Ursula
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FD=
D


--WOW2lBcncRtnPwncuvQBuCe7iqBXFo36a--

--H2GFNbTh18venRakI8gtu0aQPhJfrKgEx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJZCJjqAAoJELgmozMOVy/dPd0P/RVwhKJSWSnPCBwfpUObF6v1
TavjxAHhNf4xIsFFErdspz/w9uFWZRBKryKb/dx1YpS7cU1mCErcgb2SnRsXzBao
NcnxqFvyAj9OgpEt5PcjTpo3T3R2IspmlvOL4vXh169L/5fpgdjVeU+2fhOpEjUL
m7gUQBU9qFbXKrshkrDpC2sFlnxYyDwQCY+mALd3NY4inT3eW4hWEMVxGMn3qAaL
F8f2/dUg81bkLmo7epGiavfoGwtv756kgvCx+UTt9CyKC/OALOhTKhusqBLUN0aU
VuCiPIVCyPkNu7LCTHf0inndX7i7L6bqUMabczBevpmUmwNqqYJaARGUxIYMxFDB
1INSI/sOAs7SUMq3BhzSwU6lNzNzTvJCMoXTjxDbPc0Uu/Lk6WeJAT6JqoU3JVfi
maNv2GxmQIrFMoJMRRgHrN1IALvJ/MTf9GSJHfyUlvAOlIBaLzb6c+iD5OS39aBB
k7Qoctc+tqeK9YDP3GWKQq7zZhjFI7wL01knZwzkJ/Ny/y8CpjgQDFbEJgtzj4w9
sYdDilrKEyxmPlCjYscZvAbY5uD57Q9+jM2Pt5vk+KsMIu/SyR3lpU6qzlUIK2RL
MZtQwm5dOwnqZIXOfdNHGBHmNKeM4BOT9qlGEIzk3gaMfik/WF2mIcestzH8Dm/z
5mi7HZaiaknuu+kN71nP
=vF1K
-----END PGP SIGNATURE-----

--H2GFNbTh18venRakI8gtu0aQPhJfrKgEx--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

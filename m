From: Doug Ledford <dledford@redhat.com>
Subject: Re: mlx5 core/en oops in 4.6-rc6+
Date: Wed, 8 Jun 2016 08:48:33 -0400
Message-ID: <4a20e5d1-240e-0baf-9605-978f9a4aeb40@redhat.com>
References: <56df9c0a-39dd-6e07-9466-23195dc60860@redhat.com>
 <CALzJLG9_PLzU=Qwvv=_3aEd0KQr1c9rZyfcrfuLPo8wF=F_B0A@mail.gmail.com>
 <b4a8c4ca-74c5-b9b4-f9a5-4386cf6857fe@redhat.com>
 <CALzJLG8ho88yJStHbPg+XFtEJHDQf3s20gjnsEdRdh4mGye7FQ@mail.gmail.com>
 <79e8e8c2-6905-e9c4-b817-f5d5a21b8873@redhat.com>
 <CAKHjkjnxeLfaZ-=_60ka+gNiX90Rtkkwj2Q-UJ5_5Z9DWAeOSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="qSNGPGBohJQdpXcvgKPOX7rT4oiLoGrLH"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Linux Netdev List <netdev@vger.kernel.org>,
	ophirm@mellanox.com, Eran Ben Elisha <eranbe@mellanox.com>
To: Eran Ben Elisha <eranlinuxmellanox@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44334 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161596AbcFHMsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 08:48:47 -0400
In-Reply-To: <CAKHjkjnxeLfaZ-=_60ka+gNiX90Rtkkwj2Q-UJ5_5Z9DWAeOSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qSNGPGBohJQdpXcvgKPOX7rT4oiLoGrLH
Content-Type: multipart/mixed; boundary="K0bRQ2U0kgMDT09wo3SE46wO52kJd6Hld"
From: Doug Ledford <dledford@redhat.com>
To: Eran Ben Elisha <eranlinuxmellanox@gmail.com>
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
 Linux Netdev List <netdev@vger.kernel.org>, ophirm@mellanox.com,
 Eran Ben Elisha <eranbe@mellanox.com>
Message-ID: <4a20e5d1-240e-0baf-9605-978f9a4aeb40@redhat.com>
Subject: Re: mlx5 core/en oops in 4.6-rc6+
References: <56df9c0a-39dd-6e07-9466-23195dc60860@redhat.com>
 <CALzJLG9_PLzU=Qwvv=_3aEd0KQr1c9rZyfcrfuLPo8wF=F_B0A@mail.gmail.com>
 <b4a8c4ca-74c5-b9b4-f9a5-4386cf6857fe@redhat.com>
 <CALzJLG8ho88yJStHbPg+XFtEJHDQf3s20gjnsEdRdh4mGye7FQ@mail.gmail.com>
 <79e8e8c2-6905-e9c4-b817-f5d5a21b8873@redhat.com>
 <CAKHjkjnxeLfaZ-=_60ka+gNiX90Rtkkwj2Q-UJ5_5Z9DWAeOSg@mail.gmail.com>
In-Reply-To: <CAKHjkjnxeLfaZ-=_60ka+gNiX90Rtkkwj2Q-UJ5_5Z9DWAeOSg@mail.gmail.com>

--K0bRQ2U0kgMDT09wo3SE46wO52kJd6Hld
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 5/19/2016 1:13 PM, Eran Ben Elisha wrote:
> Hi Doug,
> Attaching here a response from Ophir Maor (from Mellanox community)

This conversation is a low priority, spare time thread for me, so it can
take a while to respond to sometimes ;-)

>>
>> Read your own guides ;-).
>>
>> I'm using this one for your switches:
>> https://community.mellanox.com/docs/DOC-1417
>>
>> And these to try and get the linux machines configured properly:
>> https://community.mellanox.com/docs/DOC-1414
>> https://community.mellanox.com/docs/DOC-1415
>> https://community.mellanox.com/docs/DOC-2311
>> https://community.mellanox.com/docs/DOC-2474
>> http://www.mellanox.com/related-docs/prod_software/RoCE_with_Priority_=
Flow_Control_Application_Guide.pdf
>>
>> The guides are helpful if your setup allows you to follow their exact
>> example.  But, they are shy on information about how to modify the
>> examples to your specific situation.  For instance, I have to use vlan=

>> priority 5 as my no-drop priority for RoCE traffic.  I can't reliably
>> tell which portions of the guide I must switch the 3s to 5s in order t=
o
>> get the new priority, and which uses of 3s in the guides relate to oth=
er
>> things that could be mapped to 5.  On a separate note, it's unclear to=

>> me if your switches and cards support more than one no-drop priority
>> (other vendor's RoCE cards I'm using here don't, they only allow one
>> no-drop priority for RoCE traffic and it must be 5).  If it does suppo=
rt
>> more than one, I'd actually like both 3 and 5 to be no-drop and for on=
e
>> vlan to use 3 and another to use 5.
>=20
> There are two flows to configure egress mapping
>=20
> - flow that pass via the kernel. Then you need to use kernel commands
> (e.g. vconfig set_egress_map, or other commands) to make the kernel
> set the egress priority.

Yes.  Done.  Which actually has nothing to do with RoCE (I don't think
even kernel RoCE flows go through this since they don't use the kernel
net stack but use the card's firmware and RoCE work requests to send
data) and is just part of the Mellanox recommended "put all traffic on
this vlan on this priority even if it isn't all RoCE".  I'm not sure I
agree with it, and explanations that specifically exclude it to make
things clearer would be nice.

> - flows that bypass the kernel such as RoCE, then you need to use
> tc_wrap to set the egress mapping.

tc_wrap is not an explanation, nor really a suitable answer to "how do I
do this" as it's out of date for the current upstream kernels last I
checked...

> This post explains it very nicely for ConnectX-4.
>=20
> https://community.mellanox.com/docs/DOC-2474

Yes, I read this post, and I downloaded tc_wrap from Mellanox, and I
dissected tc_wrap to figure out it was doing what I added to my
dispatcher file, namely this:

tc qdisc add dev mlx4_roce root mqprio num_tc 8 map 5 5 5 5 5 5 5 5 5 5
5 5 5 5 5 5 queues 32@0 32@32 32@64 32@96 32@128 32@160 32@192 32@224

But even though I was able to pull that out of tc_wrap, the explanation
of how setting what appears to be a kernel queue discipline on packets
that the kernel does not see and are handled entirely by the card causes
those packets never seen by the kernel to be sent with a specific
priority is completely missing.  What is the chain here?  Does setting
the queue discipline here translate to a setting on the card and there
is some magic in that setting that triggers the firmware to do the right
thing on RoCE packets?  Does the driver read the queue disc when setting
up address handles to use on the work requests and get the information
that way?  How is this information actually making it to the packet
generation engine in the firmware?  And given how recent upstream
kernels have changed the default queue discipline on these cards, it is
unclear how this command might need to be modified to keep working.



--K0bRQ2U0kgMDT09wo3SE46wO52kJd6Hld--

--qSNGPGBohJQdpXcvgKPOX7rT4oiLoGrLH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXWBQhAAoJELgmozMOVy/dxFEP/1F1fHllh38Gnu3KWyTO5Izg
3yZRBLTAeUV76/u33Pg3Hm0/lPZFQG/VdE67XrjCdhtzr1rXNjm5OK5jdO850g3R
sWZPUTm4wbQShGLNEU9FpjezQ09othte7NtP0DWoTyfYsuFIrPNKmPRAem+l+mHn
Z+iM4QImKdcTPOlI4bZ+8JPF0DW7XGFV1TVpzLpCCYqXQs2vK+FqdN5lTJ2WlAAy
N7pfs7lmGPrbnVwuW5Qsfjua2afqZ0MKnGFq1S+Zcof3Fy1MFFf5/EtxkCa68ogC
gOVRUAFgenvrmAQQe1mBO7WofcGr8f2dkg8mHp3EBi0trchQwScRpYtEUDiIp1do
s3nbgv35kLnCxXvcaCQLPHOPVZewWONBgfbKNb3uf4B2Qx14/XzmjVeyv9H+R416
rbq1NVywB7tLukYePrf4OmjC9uwap9tGiRR9TwbFT6hS7+VAxkvE4g5N3sCMEAti
jkS088xKXvfQqYdRZIuN64mtTCrP1l603ROZpyDeQ/WXb0mevSZLCyRIe2cyVaaA
TJfqn2qD8KWBzYgUvKk+E6ZYq9DYYjiqv3XToA0QqCP+TMzkRp6zH9bVLB5f8T48
X3/7ahDFpa2DlFyewR3naKOwRKl7UZ1XHRthmiju6lEMyEJmzM1tH03Yf3ms352R
smgkiueGilK29AFUS1iP
=MYQo
-----END PGP SIGNATURE-----

--qSNGPGBohJQdpXcvgKPOX7rT4oiLoGrLH--

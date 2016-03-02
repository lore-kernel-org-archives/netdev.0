From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next 01/10] net/core: Add support for configuring VF
 GUIDs
Date: Wed, 2 Mar 2016 11:50:43 -0500
Message-ID: <56D719E3.2000206@redhat.com>
References: <1456851143-138332-1-git-send-email-eli@mellanox.com>
 <1456851143-138332-2-git-send-email-eli@mellanox.com>
 <20160301173751.GA25176@obsidianresearch.com>
 <20160301174951.GA19366@x-vnc01.mtx.labs.mlnx>
 <20160301182516.GA12495@obsidianresearch.com>
 <CAJ3xEMgrAUCj7PS6fegmuSUsjMruH3gzSHZmuzAX+ZbHZOpL9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="jN96ciUFJbX648honqcbMPha8t3mupR3u"
Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMgrAUCj7PS6fegmuSUsjMruH3gzSHZmuzAX+ZbHZOpL9w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--jN96ciUFJbX648honqcbMPha8t3mupR3u
Content-Type: multipart/mixed; boundary="dLRlDcCUOowrxHm8iX95xhkNCp3Sio9Ae"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Message-ID: <56D719E3.2000206-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next 01/10] net/core: Add support for configuring VF
 GUIDs
References: <1456851143-138332-1-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
 <1456851143-138332-2-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
 <20160301173751.GA25176-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
 <20160301174951.GA19366-lgQlq6cFzJSjLWYaRI30zHI+JuX82XLG@public.gmane.org>
 <20160301182516.GA12495-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
 <CAJ3xEMgrAUCj7PS6fegmuSUsjMruH3gzSHZmuzAX+ZbHZOpL9w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
In-Reply-To: <CAJ3xEMgrAUCj7PS6fegmuSUsjMruH3gzSHZmuzAX+ZbHZOpL9w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>

--dLRlDcCUOowrxHm8iX95xhkNCp3Sio9Ae
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 3/1/2016 4:08 PM, Or Gerlitz wrote:
> On Tue, Mar 1, 2016 at 8:25 PM, Jason Gunthorpe
> <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
>> On Tue, Mar 01, 2016 at 07:49:51PM +0200, Eli Cohen wrote:
>>> On Tue, Mar 01, 2016 at 10:37:51AM -0700, Jason Gunthorpe wrote:
>>>>> + return handle_infiniband_guid(dev, &ivt, IFLA_VF_IB_PORT_GUID);
>>>>
>>>> But is this emulation really necessary? It seems dangerous and
>>>> continues the bad practice of assuming IFLA_VF_MAC is fixed to 6 byt=
es
>>>> in size, and is not just LLADDR bytes. I'd rather see mac sets fail =
on
>>>> IB.
>>>>
>>> struct ifla_vf_mac  already defines mac as 32 bytes but the idea here=

>>> is that applications that configure six byte Ethernet MACs to VFs wil=
l
>>> continue to work without any change.
>>
>> In my view it is incorrect for an application to try and set a 6 byte
>> mac on an *infiniband* interface, the kernel should refuse to do it.
>=20
> As Eli wrote, there's a well defined way to extend MAC to GUID. With
> that in hand, the idea here is to allow staged/evolved support for IB
> Virtualization using un-touched provisioning systems which assign VMs
> with 6-byte MACs

Exactly *what* provisioning system tries to set the VF_MAC on an IPoIB
interface and expects it to set the GUID of an underlying IB device?

> along with the fully IB aware solution where the
> upper level does provision IB GUIDs.

There has never been upstream support for this MAC->GUID stuff you refer
to.  I'm not convinced we should add it now versus just doing things
right, period.



--dLRlDcCUOowrxHm8iX95xhkNCp3Sio9Ae--

--jN96ciUFJbX648honqcbMPha8t3mupR3u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJW1xnjAAoJELgmozMOVy/dpuMQAKg62TWtNXIjWsCEQpWNs3pQ
VJH6p02Lc+D+1ilbt0hWQ0Gq9fWJcZmNr516KNCk4jvyrrYfUaVu5Zg8j28lgkxx
7LvRBCjNG13e7Rnfs1QzYz0phOovQw/E4UUF8D7lbNJUXHoXx/2dO+yZ6hQhBXNq
Xfzh+Ahg71pJaw2KYKc2RcLC3oYyhMoo6X8WmW4BNULwN6n798RFoe6kBgD6QEBL
MI+gRCwIofBn0nv3qioykRKInodEPvviOS6kokFomoaCLHuHjshV3C+dbcmyznlA
gQ3jaIXw8tgzLvMHquiiXpA8IoT02g+ibdrAqJZjjt5oK5jcK1yQTr/RAS2lLgm4
TKBFcS7z+YAYUsYKISdP5kM9RECzYn94jPT5YVO+UbA4aIQZslgyzl3GIKQNT0WY
oltjZ2SsE/PEh52OsdHqrGeq2Cd/YFVEFspprNUz/hPR6pfe7ELWdhgCrt+GJ5Py
1fGg+oC01wwgqgMURI12tzi2yPuk5BGhkH0m/vMD8AAd4jsCmS/plIoYZGqcxyv9
zaByQM/fR6AfEZkth5uzfmx4+/ZgmO1x2anC5NlJj4sDReX8KZ7YGpRIuRiNTVNu
zmJRnYW4OiwRz2ET+BSJcXe1IFRr2UUJQ8KURIBf7/hQkBUmS8tSBYcx/yP1K1s2
134q/KGrbh+UE6prW9lb
=Ultu
-----END PGP SIGNATURE-----

--jN96ciUFJbX648honqcbMPha8t3mupR3u--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Tue, 11 Oct 2016 13:41:56 -0400
Message-ID: <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161011173216.GA16892@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="vA5hsB2xeFr65TAs3FUjgd0DW0A6cgooj"
Cc: linux-rdma@vger.kernel.org, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57828 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932222AbcJKRms (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 13:42:48 -0400
In-Reply-To: <20161011173216.GA16892@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vA5hsB2xeFr65TAs3FUjgd0DW0A6cgooj
Content-Type: multipart/mixed; boundary="kHs6K67EtAgNWuXLfk7XLU6XKePiQkjeA";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
 Paolo Abeni <pabeni@redhat.com>
Cc: linux-rdma@vger.kernel.org, Sean Hefty <sean.hefty@intel.com>,
 Hal Rosenstock <hal.rosenstock@gmail.com>, netdev@vger.kernel.org
Message-ID: <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161011173216.GA16892@obsidianresearch.com>
In-Reply-To: <20161011173216.GA16892@obsidianresearch.com>

--kHs6K67EtAgNWuXLfk7XLU6XKePiQkjeA
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/11/2016 1:32 PM, Jason Gunthorpe wrote:
> On Tue, Oct 11, 2016 at 07:15:44PM +0200, Paolo Abeni wrote:
>=20
>> Also the connected mode maximum mtu is reduced by 16 bytes to
>> cope with the increased hard header len.
>=20
> Changing the MTU is going to cause annoying interop problems, can you
> avoid this?

(Paolo did the work I'm describing here, I'm just giving the explanation
he gave me):

Not using this particular solution I don't think.  We tried it without
increasing the declared hard header length and it broke when dealing
with skb_clone/GSO paths.  In order to make the LL pseudo header get
copied along with the rest of the encap and data on clone, we had to
declare the header.  The problem then became that the sg setup is such
that we are limited to 16 4k pages for the sg array, so that header had
to come out of the 64k maximum mtu.

--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--kHs6K67EtAgNWuXLfk7XLU6XKePiQkjeA--

--vA5hsB2xeFr65TAs3FUjgd0DW0A6cgooj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJX/SRkAAoJELgmozMOVy/dv4cP/Ro5Hpvmk2Q9O7QeKGDc0Wh6
QH+o5Ipz246cgV/NrEaqkMKFMupnZjiXbA7RfNXIkXiiTYLzGuJGpwM1F/G9/hIT
qHohrVMrxxTVwbhQ9o7NyYcoBaOUX7mbQc50xVGNQ3DTcg88H76HqQ+vwuTAuY8h
en5hpZG8d4ASqy8+gpajHp0jq/x3KBn0YnpC0FsA7hXJG+YmdaZ2AniWEusEf0Y4
oIU4d80ISt2k6ybq9lzyDWteOhmRo33F2rT6cLWBBdzUzkPC+iJeQJLyBUx0Doe4
wRLiW7VU/mYXefO09YFdiH+o+uyMLfqtnyKuuWF/F84t5/XnWrZsNo/pU5e2oyTI
AVbYZPrrKLLyaaurE6DrjWgMTb2zcRZnrjsYPsy6zqL5y89yqd7EmFbk0k2PinHM
Quj/ka7dXb23E6LRulRYHQgT0pSjaJ+RppVsuGXWqvNQ6qBeaeeaGzJ7JGoS3MLt
fpmBXibqFL7oQlVjxfyyvsiZKxPXqZjaHBGfhNarVNjIuNOgRr/H9obece1prWRf
YmmGpavwuyS4jAVdm4EDxr6ohwKK1H7+a1T5dd57d7dmW9DCLv8e5fZ7b/xMZX7E
2XhI6SZT4h+Foj/yLVO+JieG+ZOzuMNvsVJ3wvIR2W3KsbtfAYjamXHTU75WM9pA
gLX9Nlu0HgZW9sAb9ZQJ
=PkDJ
-----END PGP SIGNATURE-----

--vA5hsB2xeFr65TAs3FUjgd0DW0A6cgooj--

From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Fri, 31 Jul 2015 08:50:24 -0400
Message-ID: <55BB6F10.5030408@redhat.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
 <CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="CwccGGFP9UDNgrkT4mxt7wrW2TCwoAeDj"
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Somnath Kotur <Somnath.Kotur-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CwccGGFP9UDNgrkT4mxt7wrW2TCwoAeDj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 07/31/2015 05:40 AM, Or Gerlitz wrote:
> On Thu, Jul 30, 2015 at 6:33 PM, Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrot=
e:
>=20
> [...]
>=20
>> Changes from V6:
>> (1) Addressed Jason's comments:
>>         (a) Cache is no longer a client but part of IB infrastructure
>>         (b) No need for READ_ONCE and flush_workqueue when tearing dow=
n
>>             the cache
>=20
> Doug
>=20
> So... are we ready to go with V7 upstream?

Yes.  I've already pulled it in.

> Or.
>=20
>=20
>> Changes from V5:
>> (1) Incoporate the changes to cache.c so we use the same infrastructur=
e
>>     to manage both IB and RoCE (per Doug's request)
>> (2) Replace the locking mechanism in the IB core GID cache from seqcou=
nt +
>>     rcu to rwlock (addressing comments from Jason)
>> (3) get_netdev returns a helded (dev_hold) device
>> (4) Squashed the RocE GID table, RoCE GID management and default GID h=
andling
>>     code into one patch (per Doug's request).
>> (5) Change modify_gid to add_gid and del_gid.
>> (6) set the netdev related changes into three dedicated patches and ma=
ke
>>     them be 1st in the series.
>>
>> Changes from V4:
>> (1) Remove any API changes.
>> (2) Fixed a bug regarding bonding upper devices.
>> (3) Rebased ontop of Doug's k.o/for-4.2.
>>
>> Changes from V3:
>> (1) Remove RoCE V2 functionality (it will be sent at later patchset).
>> (2) Instead of removing qp_attr_mask flags, reserve them.
>> (3) Remove the kref from IB devices in favor of rwsem.
>> (4) Change the name of roce_gid_cache to roce_gid_table.
>> (5) Fix a race when roce_gid_table is free'd while getting events.
>> (6) Remove the roce_gid_cache active/inactive flag/API.


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--CwccGGFP9UDNgrkT4mxt7wrW2TCwoAeDj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVu28QAAoJELgmozMOVy/dI2IQAKT2yDUzpnX3VA0VQcZ+7h0p
IkGJ/SnsubKpcyZzy//smg4x9cISIqtkrRhG9cYJfSoLTqzRjq+gusxUL9wkwny9
tFrAYtjrzAusLTZuN2UZhjshqE+npUrQHHs6Hvw9kG6FM97ozKY+tIFT1ogqdGHc
Gn4wTXeb44eQZtfK1lDMI23ttvg8s+mSN2zylmLOgmIpSWC243dDfnjJCDpqyN64
d30I+Aatd4V8yeY+MwJf5/F8kHs7VuMlXoka6tk6M5VkCnV/UEesI0DUc32v+24o
LQw94xdV/1U+KUw7oC++J4/nbKbx4QwhekFtuY4Cmxfoi9jmsVxj44+RjUyrsh+8
YwsZWR8o01f5NkshYPCafSLNO5Su4s8t2thgCOn/RI1tUdhEpeRPxpftAdaurzwq
CIr6StrHQXaqCJegke8TPYs1gURY1xkXRcXwNjxpVngxRX2kRVdQTbOir/eMjOWP
Wxe7a/nz9QqgLKu/Zxosm248qDUpfuWH63p/7fEBo+j0GH69+SPF6hVBCkSrVNvo
ixAc8iSgvpdhZF3lAg/d16EGRb47gSCO7cwbXkpRWDNM5pgbMxIao/aiCHd3uWz4
/rrjM1E4gV+ZqQJr0c5hvbxISuv+EDeje80JPtmG1hGKcT9suKcfkdd4STGawoBV
Om3JllTPyjR3eUbJ6ACJ
=DksC
-----END PGP SIGNATURE-----

--CwccGGFP9UDNgrkT4mxt7wrW2TCwoAeDj--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

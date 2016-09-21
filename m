From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/15] i40e: Introduce VF port representor/control
 netdevs
Date: Wed, 21 Sep 2016 14:23:28 -0700
Message-ID: <1474493008.3936.72.camel@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
         <1474429432-102772-2-git-send-email-jeffrey.t.kirsher@intel.com>
         <CAJ3xEMhtyrS_jKrZ8UYWDi-UjK4RuxbwUSs8H=nFqWrTgzDVdw@mail.gmail.com>
         <57E21E74.5090707@intel.com>
         <CAJ3xEMgMkz1FZ-QObMvc28JQT0Osrf-k7_RfanUYkYP=F8jZGQ@mail.gmail.com>
         <57E2BC74.5040905@intel.com>
         <CAJ3xEMj-teLmjg+Nzn0pHsnz8P=EY6uF4VzDJsxVEOTihStrLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-WPRrTYrX3/dUr88Kcal2"
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        guru.anbalagane@oracle.com, Ilya Lesokhin <ilyal@mellanox.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Rony Efraim <ronye@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31563 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757145AbcIUVXa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 17:23:30 -0400
In-Reply-To: <CAJ3xEMj-teLmjg+Nzn0pHsnz8P=EY6uF4VzDJsxVEOTihStrLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WPRrTYrX3/dUr88Kcal2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-09-21 at 22:21 +0300, Or Gerlitz wrote:
> On Wed, Sep 21, 2016 at 7:59 PM, Samudrala, Sridhar
> <sridhar.samudrala@intel.com> wrote:
> > On 9/21/2016 12:04 AM, Or Gerlitz wrote:
>=20
>=20
> >> so what happens after this patchset is applied and before the future
> work is
> >> submitted? RX/TX slow path through the VFPRs isn't supported and what
> >> about fast path? in other words what happens when someone
> >> loads the driver, sets SRIOV (--> the driver set itself to switchdev
> mode
> >> and VFPRs are created) and then a VF sends a packet? do you still put
> >> into the HW the legacy DMAC based switching rules? I am not
> following...
>=20
> > The VF driver requests adding the dmac based filter rules via mailbox
> > messages to PF and that is not changed in this patchset.
> > Once we have VFPR TX/RX support, we will not allow the VF driver to add
> > these rules, Instead a host based
> > program will be able to add these rules to enable the fast path.
>=20
> I see, this means that when this patch set is applied your driver
> reports through devlink that they are in switchdev mode, but the
> operational state of the VFs and VFPRs isn't such - as the VFs dictate
> the steering and the VFPRs don't support slow path TX/RX --- in an
> earlier comment you made on this thread you said that you will be
> submitting RX/TX support in the next patchset. Maybe it would be best
> if you can take the VFPRs patches out of this series and roll a follow
> up series with all what's needed? unless you need more time and gonna
> miss 4.9 as of that... if the patches are ready, I say lets have them
> all in one series, if not, I wonder what other people think on the
> matter. I am basically half+ good to have also the half baked code
> base merged
>=20
> Anyway, there's no point to report through ethtool something (VF vport
> HW stats) you can report in the standard and convenient manner, so
> this one please do address regardless of the prev comment.

I will drop Sridhar's changes from this series for now, so that he can do
the re-work AND provide the additional patches he referred to earlier at a
later date.
--=-WPRrTYrX3/dUr88Kcal2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJX4vpRAAoJEOVv75VaS+3OCRkQAJi2Y/ygKnZ4n0U3Y2b4xdNL
DWV8Hh14erb/V//HiUWpo/ZTh8PekXng29OlnmHMux4ojMsUvL8aJ9U5uCk77QOx
2Lb8Kw45U899Kf/A/U2lvnN8emGfUx0/OJ2JH2xZLRfJ6c3/cokKCpsSI55JpYuV
37cvaLNbbqn9+lmpitw/1N8eYi8AtziBwhhGFitxEo2/9mSmO0lh1EXLCW0Bvl35
+zo+Sb04Jzxe+SfaYVkvE78bLq7juSM0cV4F8rEy7VYeQ909HUsy0XOhkevnmYX6
a3QtPxQHfh8NG20A7MUJ2UXjdsxj2XbYl+xbHemmqzJzDw7md0ocICqB7njFya3F
EoBFqQUHlQcacVFbI/qZNcAwlOuAwIuEI7MEmTnPTIW/7/6WmayFQ9lzsGkRivIR
1sCkF1KhP4rxYKC9XnVZPK/3uxHeQCwoW/55aEGgagwofc5Q+jizIYOkJJBIsIMH
7B9GgldtZXui1Q5iWQeNHl2cnkIfUm2eWsZNZKPAEdjVhFGUFOJ/9Wje0AXAttIg
eOot74DKxxsf4w9wZLI8dWI6+jNQuYLvUrQCNTAT7S5iEBtS7ueEbjSu8zhFT2o6
2hqO5RRfuFGUyQS6r2rrSlQOF+YsuYLboQpDelIe7iZgX3NvPF1pDdOfcHqpeYxV
8Cu7WgVd3K8bf0dPn2M8
=0FvE
-----END PGP SIGNATURE-----

--=-WPRrTYrX3/dUr88Kcal2--

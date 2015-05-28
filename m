From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 28 May 2015 10:07:37 -0400
Message-ID: <1432822057.114391.26.camel@redhat.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	 <1432647280.28905.107.camel@redhat.com> <55671309.6080303@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-NGxrxuBHky+zmbklT4H8"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55671309.6080303-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-NGxrxuBHky+zmbklT4H8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-05-28 at 16:07 +0300, Haggai Eran wrote:
> On 26/05/2015 16:34, Doug Ledford wrote:
> > On Sun, 2015-05-17 at 08:50 +0300, Haggai Eran wrote:
> > This is a core feature more than anything else.  Namespaces for RDMA
> > devices is not unique to IB or RoCE in any way.  Yet no thought has bee=
n
> > given to how this will work universally across all of the RDMA capable
> > devices (mainly I'm talking about iWARP here...
> I don't agree. It is true we have are not planning to provide an iWarp
> implementation for network namespaces, as we lack the capacity and the
> expertise. However, I think that the changes we proposed to the rdma_cm
> module will work with iWarp too. Perhaps with some of Jason's
> suggestions it will be smoother, but even in the current design, I think
> that if iWarp drivers can provide iw_cm with the network device on which
> a request is received, then it should be simple to modify it for
> namespace support without significant change to rdma_cm.

My request wasn't for a functional implementation, just a statement that
you had in fact thought about it and, as you say here, would expect it
to work (and preferably why as well).

> Well, because the RDMA subsystem supports a very diverse set of devices,
> I think there are few people who know the details of all hardware types
> well. If we are going to evolve the generic parts of the stack, we have
> to cooperate. We have to rely on the knowledge of people on the mailing
> list to say whether the feature is well designed for all hardware types,
> or whether changes are warranted. In this specific case, the patches has
> been on the list since February. I think it is enough time to allow
> anyone who is interested in network namespace support to chime in.

You would think that, but sometimes important information comes from
totally different places.  See mine and Jason's comments back and forth
in the SRIOV thread started by Or.

Long story short:

ip link add dev ib0 name ib0.1 type ipoib

is totally broken on at least all Red Hat OSes.  It will require
reworking of the network scripts and NetworkManager assumptions to make
it work.  It will also break DHCP on the interface as pkey/guid are the
only items that uniquely identify DHCP clients.  The net result of our
talks was that it is likely that each interface on the same pkey will
require an alias GUID per child interface in order to keep things
workable.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD


--=-NGxrxuBHky+zmbklT4H8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVZyEpAAoJELgmozMOVy/dkFEQAKxcUKeseMVSVkHu9ttMOG9a
P076MiG5+vN4GowdoMCK6BGQMfZvUW6Ao4f9v/dRYsQlJVk6JcRPyVw/GMkQwf4K
2rneRg4DtCpf672sFFaxfyT1z8pmb+l91J1jN9o/tCzbW9x/ulwCylcg2xaJSLJv
IrnS3uLhU+KoRYV8QIy/dQRV6Sz+GzkD5r40VkCdMNI3jqc5bo2JqSVZ9cLRrbnb
YITp5sqj7HPSmeI067JYBrTzlJDrNOCUksybL7IM1rVjyyDpsim6nLIaNpcTiyGE
9vfsyxuyCym/3Ykcv3n9XAhKBCrSxeCAFERw0T/cBaFwNExgIeHLD5IaGjljaQjg
pizoCYcnQUtn6pKHgZxPq5d7+IFVh7IEJdV5FYqg6yPGVX9uu85dpp4TwTVryAaG
3fQRO3JCewYdzwpTcGgW3pb+mYSAY8SM9e0F6kobSNMQxO2BIN0EZbA7hKDlscFd
PyHKDDOXTzCDlZt0Q4VEi1Zj3+7rV8IUJsU7tP+nrWD0wBjhPhm/ik9+AJsVVJrz
g87le46MCZLEBiZrIaEr84ND9zLDB2VTkyXRLkhdvXnUCEikJEYqlQ/woTZ3ySFp
Q+wthBEczu549FhxLZQDxQ83+Xto2zpVKJGXOM2LGUIWI51PR0IxmSs+QuMa1SGn
hhwmaJidHNPz51K7Ymd6
=Jb3q
-----END PGP SIGNATURE-----

--=-NGxrxuBHky+zmbklT4H8--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

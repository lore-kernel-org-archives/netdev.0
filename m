From: David Gibson <dgibson@redhat.com>
Subject: Re: [RFC 4/4] tuntap: Increase the number of queues in tun
Date: Mon, 25 Aug 2014 11:37:40 +1000
Message-ID: <20140825113740.d2bf59c3784ebab592bdf6e9@redhat.com>
References: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
	<1408369040-1216-5-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__25_Aug_2014_11_37_40_+1000_MLrG1N.BdfWdLhV6"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, wuzhy@linux.vnet.ibm.com, xemul@parallels.com,
	therbert@google.com, bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408369040-1216-5-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__25_Aug_2014_11_37_40_+1000_MLrG1N.BdfWdLhV6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 18 Aug 2014 19:07:20 +0530
Pankaj Gupta <pagupta@redhat.com> wrote:

> Networking under kvm works best if we allocate a per-vCPU RX and TX
> queue in a virtual NIC. This requires a per-vCPU queue on the host side.
>=20
> It is now safe to increase the maximum number of queues.
> Preceding patches:
> 	net: allow large number of rx queues
>   	tuntap: Reduce the size of tun_struct by using flex array
> 	tuntap: Publish tuntap max queue length as module_param
>=20
> 	made sure this won't cause failures due to high order memory
> allocations. Increase it to 256: this is the max number of vCPUs
> KVM supports.
>=20
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>

Reviewed-by: David Gibson <dgibson@redhat.com>

--=20
David Gibson <dgibson@redhat.com>

--Signature=_Mon__25_Aug_2014_11_37_40_+1000_MLrG1N.BdfWdLhV6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJT+pNlAAoJEGw4ysog2bOSCkcQAMeq9Zt58PYJVO2TjQalLuiM
ek8X1bGgCGeKHJjRqBkzs6vmkLBPF5xzUZWdJvwEykWMcXQiwL8hWibBJcftt03O
HoqGpAxGc8jawAgxYL8nGrocdAkzTo5wAgDZLUdOI+cMDNK4O0r8bzMwHQ779Lcp
VqZjPrJyu0vBeoOjE8nWc+nHz/zy9Z9kiq0VrIlPMmdQ9mzPnFXMRvYExYLWIQGV
dR/oyjW2Wi1msypfF+dVK22VjLkBaW1lnvzRL7FeiKEptBIKuQQnrYVxeYkrwLrV
S2gGpMQbuuC0EHra5Z3gCRaEYJdpIof38PDh0tv3ypant8dXrXXZfG0qKqr96LXt
xZB+JeiCg19z6cFU/wIPT4dDnKEgR68yceGiizNFyuBjw+G0ynFotVEbhWdaB4fP
N6/iVO0v/WNndwUMQEfo5uIlYIfBZQIRTAx/hkR788kevgCiTeRWrotk9YYD7aE2
6iZ/F9YjGqSn3JCjOt7qDSPwwnZUYFdr90ruC2S6qTEXDc8zsHg8mCgS279Hqk/L
Eex790ZXLrcor0X5DEfVbGg6tRRUPUp78ku6t/Oj6SvcWZSFeZetawxIApltT2Je
gI/7eJ/WReZ4rsjZtusoVTjAXZzz73b7NZKrClo0KCc+kCfIxpWgKL9Jg1hvYBET
yvVGmI8/rztqt3kQ29PS
=PDAl
-----END PGP SIGNATURE-----

--Signature=_Mon__25_Aug_2014_11_37_40_+1000_MLrG1N.BdfWdLhV6--

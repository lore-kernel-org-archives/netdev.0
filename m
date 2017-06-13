From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 01/44] firmware/ivc: use dma_mapping_error
Date: Tue, 13 Jun 2017 14:35:38 +0200
Message-ID: <20170613123538.GB16758@ulmo.fritz.box>
References: <20170608132609.32662-1-hch@lst.de>
	<20170608132609.32662-2-hch@lst.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3027311718705588637=="
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org,
	x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170608132609.32662-2-hch-jcswGhMUV9g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============3027311718705588637==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="2B/JsCI69OhZNC5r"
Content-Disposition: inline


--2B/JsCI69OhZNC5r
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08, 2017 at 03:25:26PM +0200, Christoph Hellwig wrote:
> DMA_ERROR_CODE is not supposed to be used by drivers.
>=20
> Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
> ---
>  drivers/firmware/tegra/ivc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Acked-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

--2B/JsCI69OhZNC5r
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAlk/3BoACgkQ3SOs138+
s6HPehAAsPH3WCVEat0HG8XtDXXMKUx9atqqkjijlfz3wzr3Yu8oeWJkmauxBI2J
xWvBLcQSO632cLKWDXp9sfnjUN9McgOQi4LbbEnJZ3Wzovtn86aaPUXEtbrUImTw
P57+RXkSbiFiGp8LlUECzxlshCYZHbzvOmqvdxpBqOTjQfv7fehxm+SVPJgkRflE
EUuCItQsdBhnqBOtq743sf7Ck4QJ3Kz4pLGgntIDINnwiPxWjpMpI06SeVnvK2st
d5lq46pyBdS3dliCsRcn6jukf79HzS/jStxG8r5YCEkRfCPvw0au5ds8iywvCZrZ
hJYP0tumPW9j/x0ZC35a6j4dIbotmuhqCE2mYJUjG2mKDtAtdqZKVBvwKUmxzGok
H7YKQDZN54UOBVg4Rzsbu80eyYc2jFZEWIhICrQUYVM534Psw7LGnA6hMiv5X8aS
J4T7cOnL+71/iwE9Ey5EdvTbV22/mcx711OcyPbZ7q5Dv4AZE9HdJrPTF1rf1TeA
WDqgA3BbY6JNflUayq5in0OxeyN8/qKbJr9ozhXgCNKNUUH5nihjT4LZxENEWV2p
pRCppkKHw9Wmze/9cDuINms2Ef1DlEzxJ9BqE5mtiFFsCq1mn9EUxgMt4vbbfMqC
Ynk0gIB134Hm0HIXoJcwdQ/27Ltko3nyeRm+28ka/gS8GVgYtec=
=jGwQ
-----END PGP SIGNATURE-----

--2B/JsCI69OhZNC5r--

--===============3027311718705588637==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============3027311718705588637==--

From: Felipe Balbi <felipe.balbi@linux.intel.com>
Subject: Re: [PATCH net-next 4/5] treewide: replace dev->trans_start update
 with helper
Date: Wed, 04 May 2016 11:14:45 +0300
Message-ID: <87vb2udytm.fsf@intel.com>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
 <1462285994-31983-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0612351183774410813=="
Cc: devel@driverdev.osuosl.org, linux-xtensa@linux-xtensa.org,
 linux-omap@vger.kernel.org, linux-scsi@vger.kernel.org,
 user-mode-linux-devel@lists.sourceforge.net, linux-s390@vger.kernel.org,
 linux-rdma@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-usb@vger.kernel.org, Florian Westphal <fw@strlen.de>,
 linux-can@vger.kernel.org, linux-bluetooth@vger.kernel.org,
 linux-parisc@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
 linux-hams@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
 MPT-FusionLinux.pdl@broadcom.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1462285994-31983-1-git-send-email-fw@strlen.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

--===============0612351183774410813==
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi,

Florian Westphal <fw@strlen.de> writes:
> Replace all trans_start updates with netif_trans_update helper.
> change was done via spatch:
>
> struct net_device *d;
> @@
> - d->trans_start =3D jiffies
> + netif_trans_update(d)
>
> Compile tested only.
>
> Cc: user-mode-linux-devel@lists.sourceforge.net
> Cc: linux-xtensa@linux-xtensa.org
> Cc: linux1394-devel@lists.sourceforge.net
> Cc: linux-rdma@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: MPT-FusionLinux.pdl@broadcom.com
> Cc: linux-scsi@vger.kernel.org
> Cc: linux-can@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linux-omap@vger.kernel.org
> Cc: linux-hams@vger.kernel.org
> Cc: linux-usb@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org
> Cc: linux-s390@vger.kernel.org
> Cc: devel@driverdev.osuosl.org
> Cc: b.a.t.m.a.n@lists.open-mesh.org
> Cc: linux-bluetooth@vger.kernel.org
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

for u_ether.c:

Acked-by: Felipe Balbi <felipe.balbi@linux.intel.com>

> diff --git a/drivers/usb/gadget/function/u_ether.c b/drivers/usb/gadget/f=
unction/u_ether.c
> index 637809e..a3f7e7c 100644
> --- a/drivers/usb/gadget/function/u_ether.c
> +++ b/drivers/usb/gadget/function/u_ether.c
> @@ -597,7 +597,7 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
>  		DBG(dev, "tx queue err %d\n", retval);
>  		break;
>  	case 0:
> -		net->trans_start =3D jiffies;
> +		netif_trans_update(net);
>  		atomic_inc(&dev->tx_qlen);
>  	}

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXKa91AAoJEIaOsuA1yqREa0UP/35SFn4ZofIoB65PTj1xg8X/
n7p9jjvrvEml10E4POQ/ZKeKzNBobiZfTvPVQ5fJ3DeaxYRMFNldcoNvv3XLHgb1
J/A6NNdCBYPMo7cc/67RCJKC+NEMbplqQSrLyCL4N8KDaR0ToDvFOhDW5ENtYAFR
+hHewPpprXHex8FPax3PMuuNCRkV/hz3PxCXnF+1h5nKD3hsXZwzQQAVC4OkWkzo
f9pAczgygfMWpsdOK4lBqAf82sK9P/bOJoE7ag/6zJ3E8EvmiB2oqtBzWzpdpWgL
JAZ4O8g2q2eV+vXK8ZqMt/yUwdS+V0ouR+iReYAATahEXzu0XPRZSHwmL0qKbl/D
RN4cVtSHl9cYltkxEMUSNUWZhGDaAyOiYbWWXwDQvus915p5Nq41v2VJailJBQD0
w+K4gJAw+0igWKgvq1M/JwoJftk9cA75Dw18f+6T6j/e78k0ZCnj1F4WHjWAIAAm
b54FVVjKATCK8/vIl73vtUpgdAzYeue3mwfd+PP5UfMXRpcEZU2icEyvHgyvbU5U
ChlCb1NRYIJ01e+J5Ov/Xd6+Pln8EwV4W4imFjzcsLNjiVU0OumWVqFqPtlDd4tq
5rKSXFa4XdaMA0CAM48AjdQmE3ta+xFFe+Q0GqVTMgyc4QOvSmZuWmsdfTmgyqC+
DjWMdryqMVHstUt2mUPA
=NJVp
-----END PGP SIGNATURE-----
--=-=-=--

--===============0612351183774410813==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============0612351183774410813==--

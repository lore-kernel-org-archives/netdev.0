From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 12/15] i40evf: make checkpatch happy
Date: Wed, 19 Nov 2014 01:55:08 -0800
Message-ID: <1416390908.2295.58.camel@jtkirshe-mobl>
References: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416370256-16834-13-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416373185.6651.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-O6eiYZop2+iuVJeFPxu6"
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5744 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785AbaKSJzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 04:55:12 -0500
In-Reply-To: <1416373185.6651.12.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-O6eiYZop2+iuVJeFPxu6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-18 at 20:59 -0800, Joe Perches wrote:
> On Tue, 2014-11-18 at 20:10 -0800, Jeff Kirsher wrote:
> > This patch is the result of running checkpatch on the i40evf driver wit=
h
> > the --strict option. The vast majority of changes are adding/removing
> > blank lines, aligning function parameters, and correcting over-long
> > lines.
>=20
> Hey Mitch, Jeff:
>=20
> > diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/=
net/ethernet/intel/i40evf/i40evf_main.c
> []
> > @@ -1265,8 +1269,8 @@ int i40evf_init_interrupt_scheme(struct i40evf_ad=
apter *adapter)
> >  	}
> > =20
> >  	dev_info(&adapter->pdev->dev, "Multiqueue %s: Queue pair count =3D %u=
",
> > -		(adapter->num_active_queues > 1) ? "Enabled" :
> > -		"Disabled", adapter->num_active_queues);
> > +		 (adapter->num_active_queues > 1) ? "Enabled" : "Disabled",
> > +		 adapter->num_active_queues);
>=20
> You could add a newline to that format one day.
>=20
> > diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/driv=
ers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
> []
> > @@ -711,7 +712,6 @@ void i40evf_virtchnl_completion(struct i40evf_adapt=
er *adapter,
> >  				"%s: Unknown event %d from pf\n",
> >  				__func__, vpe->event);
> >  			break;
> > -
> >  		}
> >  		return;
> >  	}
> > @@ -776,7 +776,7 @@ void i40evf_virtchnl_completion(struct i40evf_adapt=
er *adapter,
> >  		break;
> >  	default:
> >  		dev_warn(&adapter->pdev->dev, "%s: Received unexpected message %d fr=
om PF\n",
> > -			__func__, v_opcode);
> > +			 __func__, v_opcode);
> >  		break;
> >  	} /* switch v_opcode */
> >  	adapter->current_op =3D I40E_VIRTCHNL_OP_UNKNOWN;
>=20
> And be consistent with PF vs pf usage too.

Thanks for noticing, I had not caught that there was inconsistent use.
I try to catch acronyms that are not capitalized, and after looking
through the code, I see that there is inconsistent use of VF vs vf as
well.  I am putting together a patch now that will make the use of both
acronyms consistent throughout our code.

--=-O6eiYZop2+iuVJeFPxu6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUbGj8AAoJEOVv75VaS+3OFbIP/Ao4htx0rP0A8jc5/h74CfwZ
8wj3OHvAzcK7Cye3KMFxVilIf3xmIe/g8uj4Py+jjzseJ07vUBubUySXfpn4MfzG
TNNDruhTrNnLpMdLT6e2PERvwDBDYafpsV+Kce4AHWvNFGmlKhi/i09+BVsCYmoW
/Y4lrpsgG+vI7TXa/gQtJESQSGof82gfFiIySngpLG2OQq/j76PANS/LaHEO/Tbd
6UpUIxuz7tD5Rjo5I6/boh15WdPpxUPT7PUh0RoiiT26A27mTr8dOGufVp7M95C3
hKToUHj8VMd7NOmPWv1EFP5GY++kbE8HI6W0HryG/Bwpy9BUuEJEV2JlbdxoEEr6
r02hwgymXpheiech9T9ZrI/RqITaC/rI69tk38Fypz3Iy0priTrmPaovS15FMJFU
HCPJX973tTZfFEx4+c3ulA3qZQjAwPGyihQASeMUSur+zNAanoM8HGAHRZj1S1cU
fai1kyKxVxTxA4MOaxqyetV8TrkxdBY7JFqt8PCdbjF+MsOCNKwxiKZOup52K0uS
yl4ZhnHhLiIbO7N1pVu/JIbt0Ph2bdsJAAX2wHD/UC4VfMrYsEvU+JCzNvRxPD63
9xBKD0dtDNgN4bHNcBSshJjXRx874R2Hs30FulsoaAwprnm1tVAIwjXLP4+DfrCZ
34ObW4GnoXVCuRmPs+nK
=Vrn0
-----END PGP SIGNATURE-----

--=-O6eiYZop2+iuVJeFPxu6--

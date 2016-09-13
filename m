From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Tue, 13 Sep 2016 13:16:16 +0300
Message-ID: <20160913101616.GT8812@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
 <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
 <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
 <20160913063806.GP8812@leon.nu>
 <BL2PR07MB2306937C8C495DB80DA776CA8DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="8+OS07CeIgZ706fH"
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Mark Bloch <markb@mellanox.com>,
        Ram Amrani <Ram.Amrani@qlogic.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        David Miller <davem@davemloft.net>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        Michal Kalderon <Michal.Kalderon@qlogic.com>,
        Rajesh Borundia <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46690 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756243AbcIMKQW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 06:16:22 -0400
Content-Disposition: inline
In-Reply-To: <BL2PR07MB2306937C8C495DB80DA776CA8DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8+OS07CeIgZ706fH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 13, 2016 at 07:18:01AM +0000, Mintz, Yuval wrote:
> >> >> +uint debug;
> >> >> +module_param(debug, uint, 0);
> > >>> +MODULE_PARM_DESC(debug, "Default debug msglevel");
> >>
> >> >Why are you adding this as a module parameter?
> >>
> >>  I believe this is mostly to follow same line as qede which also defines
> > > 'debug' module parameter for allowing easy user control of debug
> > > prints [& specifically for probe prints, which can't be controlled
> > > otherwise].
>
> > Can you give us an example where dynamic debug and tracing infrastructures
> > are not enough?
>
> > AFAIK, most of these debug module parameters are legacy copy/paste
> > code which is useless in real life scenarios.
>
> Define 'enough'; Using dynamic debug you can provide all the necessary
> information and at an even better granularity that's achieved by suggested
> infrastructure,  but is harder for an end-user to use. Same goes for tracing.
>
> The 'debug' option provides an easy grouping for prints related to a specific
> area in the driver.

It is hard to agree with you that user which knows how-to load modules
with parameters won't success to enable debug prints.

In addition, global increase in debug level for whole driver will create
printk storm in dmesg and give nothing to debuggability.

Thanks

--8+OS07CeIgZ706fH
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX19HwAAoJEORje4g2clinOscQAKJKA/na00GeIY+82Gq1s55/
LCEp9IfD4WN8jAsqRzSwUUJlYMmmT2hi2VCVmFRQBoArkcGfJpTtzs02NEqqCk4d
Eoit/keuwFwMjA/H6OmY2YPGJbCIvLCeA6AUiiUunAN0U4XwsKdEWDtEfWJlVd3z
x+zXHAsBuidWz+XC8VP6hVjNrMu708hRN6tv4fjIGLt+CFu0gtjlyqLbUyQwfdtn
J1ulS7J6I4uWhw8APl/L5sUn+PoM/W0S5ruVNkI4XmqerxX+UL20I34vWPGBF0Yb
ETufD2WqLjEGXY1CpmCaINEIJMZjXDFztMmppyr69Lr0+LJBAcVAyrpnJgJjZZm/
ETUUbcfeKnnnXkZDEAJJhPdO7b07SDOpU863US0rpQM6mmEcvv2Yr5Bl9ZgphABT
7Vt3G9J4xIgZV03j3qKk6coWoly73PhOomXC6AZHHByYRNEzBAvAXLfijMQiV1V8
32uGmJzgdAxjZ/7n1Wcste8sI+J8VgdHxifp7jhF9FXtxI73zrtrAO1Ca4cPv/YI
E3aWksbH/UwgEgKnohwsIAxBFzE80EgRY7Z9W3M00lYG8/TQFIzgMjApqQlf1p4v
p1dZ8t9MVTxxxp91t8jiaah/i0+P7hGg6JCb33rJ0tx0Wtks/XlZVmJkWN6oxWL5
5xwD8Vc2OVzfdXEMNN3R
=DdtV
-----END PGP SIGNATURE-----

--8+OS07CeIgZ706fH--

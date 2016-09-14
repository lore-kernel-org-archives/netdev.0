From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Wed, 14 Sep 2016 16:00:32 +0300
Message-ID: <20160914130032.GB26069@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
 <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
 <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
 <20160913063806.GP8812@leon.nu>
 <BL2PR07MB2306937C8C495DB80DA776CA8DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160913101616.GT8812@leon.nu>
 <BL2PR07MB2306533A710B9EC40F56E8678DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="gatW/ieO32f1wygP"
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
Received: from mail.kernel.org ([198.145.29.136]:37834 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761788AbcINNAq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 09:00:46 -0400
Content-Disposition: inline
In-Reply-To: <BL2PR07MB2306533A710B9EC40F56E8678DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gatW/ieO32f1wygP
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 14, 2016 at 08:15:23AM +0000, Mintz, Yuval wrote:
> > > >> >> +uint debug;
> > > >> >> +module_param(debug, uint, 0);
> > > > >>> +MODULE_PARM_DESC(debug, "Default debug msglevel");
> > > >>
> > > >> >Why are you adding this as a module parameter?
> > > >>
> > > >>=A0 I believe this is mostly to follow same line as qede which also=
 defines
> > > > > 'debug' module parameter for allowing easy user control of debug
> > > > > prints [& specifically for probe prints, which can't be controlled
> > > > > otherwise].
> > >
> > > > Can you give us an example where dynamic debug and tracing infrastr=
uctures
> > > > are not enough?
> > >
> > > > AFAIK, most of these debug module parameters are legacy copy/paste
> > > > code which is useless in real life scenarios.
> > >
> > > Define 'enough'; Using dynamic debug you can provide all the necessary
> > > information and at an even better granularity that's achieved by sugg=
ested
> > > infrastructure,=A0 but is harder for an end-user to use. Same goes fo=
r tracing.
> > >
> > > The 'debug' option provides an easy grouping for prints related to a =
specific
> > > area in the driver.
> >
> > It is hard to agree with you that user which knows how-to load modules
> > with parameters won't success to enable debug prints.
>
> I think you're giving too much credit to the end-user. :-D
>
> > In addition, global increase in debug level for whole driver will create
> > printk storm in dmesg and give nothing to debuggability.
>
> So basically, what you're claiming is that ethtool 'msglvl' setting for d=
evices
> is completely obselete. While this *might* be true, we use it extensively
> in our qede and qed drivers; The debug module parameter merely provides
> a manner of setting the debug value prior to initial probe for all interf=
aces.
> qedr follows the same practice.

Thanks for this excellent example. Ethtool 'msglvl' adds this
dynamically, while your DEBUG argument works for loading module
only.

If you want dynamic prints, you have two options:
1. Add support of ethtool to whole RDMA stack.
2. Use dynamic tracing infrastructure.

Which option do you prefer?

>

--gatW/ieO32f1wygP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX2UnwAAoJEORje4g2clinXrUP/2jArl7b+PGt0i9yxTsJrdxO
URi5euxXshp4XLpbPoayz9+GKiFwol7cA/8S6nYUqNWYCeQiAD9uoVWpzip6y5jt
iFtYs6z/FQY/mJr3LYjeuAk98B0a0/lPqAJNRwJCZQf3GqVCN4Bz7ktayEd8lNlN
G7CMSmPe6iIPfMWB/IZlS1VY2BBeUS+dwuOrn0ipBwncKU1w6m1jm7k5k17lZOIJ
m/Wj02mJKy8HB4rq87gb4jPqTDGaOTZAOG2Wl7mGevpZPlMz5kXlylEMxLQaLNkO
6duig4IT6KVXvrA8XRm/xN1ibzf4saySG0lQpL/8qxaTauPljLl5ts7AQ5egb9RW
anqkaTSMVRZgYWvGfeGzgr+SGU/tFP3UwRYwf4ZvlQCrCu5zFntAKVAvIs2o6s6+
/zWW9C0OEvZ7Qg6oK4OJhJA9YolXh/Hzb6zEzOIErcxq4bzLPNagmKIgIPT0Qmmo
r0CuQJcznhxrRICyZz7Z8LriL6JtlsyaFupHL/ZPiEWsGJrHXNp2dzYDrO5rOmEN
Mhjn4cIvmnnWo0TlHYGHaQD237IE1LBXf7u9el02WfI2Sc+cdgYLs8NAZjtwcCQ8
jgGdIanvpro+DhSeDCLtamUroFcXiju5gWYxS9IIVVbcMkEV0VM7NityGecRO583
FkcvMHOkUa/oQ/2pP+VT
=EsM4
-----END PGP SIGNATURE-----

--gatW/ieO32f1wygP--

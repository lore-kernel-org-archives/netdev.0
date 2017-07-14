From: Harald Welte <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next v1 1/3] gtp: refactor to support
 flow-based gtp encap and decap
Date: Fri, 14 Jul 2017 10:03:16 +0200
Message-ID: <20170714080316.vlqgtao3fznpsuur@nataraja>
References: <20170713004455.3946570-1-ouyangj@fb.com>
	<20170713004455.3946570-2-ouyangj@fb.com>
	<20170713072624.iinvf7sqiwn6abff@nataraja>
	<3729E0DA-08AB-4C5C-B9EC-C76DAAA60E10@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"osmocom-net-gprs-qjLDD68F18N4m7O/Vxda39i2O/JbrIOy@public.gmane.org" <osmocom-net-gprs-qjLDD68F18N4m7O/Vxda39i2O/JbrIOy@public.gmane.org>,
	"pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org" <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3729E0DA-08AB-4C5C-B9EC-C76DAAA60E10-b10kYP2dOMg@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jiannan,

 =

> > >   gtp =3D netdev_priv(dev);
> > > + gtp->net =3D src_net;
> >=B7
> > Isn't this a generic change that's independent of your work on OVS GTP?
> =

> It is meant to be OVS independent. What makes it not? Should I leave =

> this field un-initialized?

In general, in all FOSS projects I have worked (and particularly the
Linux kernel), it is a strict rule that any given patch adresses only
one logical change.  So if your change is for flow-based "OVS" support
in the GTP code, and the "gtp->net =3D src_net" is a generic change (and
not something specifically required by flow/OVS) then it should be a
separate patch.  Similarly to the cosmetic changes which should be a
separate patch.

-- =

- Harald Welte <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org>           http://laforge.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

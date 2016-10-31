From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
Subject: RE: [PATCH net-next V3 0/9] liquidio CN23XX VF support
Date: Mon, 31 Oct 2016 07:21:27 +0000
Message-ID: <DM3PR07MB21386FE887D71590E16ED59B81AE0@DM3PR07MB2138.namprd07.prod.outlook.com>
References: <1477443430-27170-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <20161029.143126.1818409172503412109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_002_DM3PR07MB21386FE887D71590E16ED59B81AE0DM3PR07MB2138namp_"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0048.outbound.protection.outlook.com ([104.47.34.48]:51941
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1763115AbcJaIz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 04:55:56 -0400
In-Reply-To: <20161029.143126.1818409172503412109.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_DM3PR07MB21386FE887D71590E16ED59B81AE0DM3PR07MB2138namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable


Hi Dave,

Regarding module parameters num_queues_per_{p,v}f, in non-default case if u=
ser wants to have multiple queues then because of the way Liquidio HW works=
 we need num_queues_per_pf and num_queues_per_vf module parameters at HW/mo=
dule init time. This is because in multi-queues per VF scenario, HW has to =
carve these queues before FW can start communicating with PF/VF host driver=
s. So we must include these two parameters incase more than queue is needed=
 by VF.

I did not get reply from you when I requested you for confirmation couple o=
f weeks back about the same two module parameters as shown in the mail atta=
chment.=20

So please confirm if you want us to remove these two parameters num_queues_=
per_{p,v}f. Then I can remove these module parameters and resubmit the patc=
hes.=20

Thanks and Regards
Raghu.




> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, October 29, 2016 11:31 AM
> To: Vatsavayi, Raghu
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next V3 0/9] liquidio CN23XX VF support
>=20
> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
> Date: Tue, 25 Oct 2016 17:57:01 -0700
>=20
> > 2) As recommended by you removed custom module parameter max_vfs.
>=20
> I feel the same way about num_queues_per_{p,v}f.
>=20
> What's really strange is that there is a reference to num_queues_per_pf i=
n
> one of the kernel log messages already.

--_002_DM3PR07MB21386FE887D71590E16ED59B81AE0DM3PR07MB2138namp_
Content-Type: message/rfc822
Content-Disposition: attachment;
	creation-date="Mon, 31 Oct 2016 07:21:26 GMT";
	modification-date="Mon, 31 Oct 2016 07:21:26 GMT"

From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
To: David Miller <davem@davemloft.net>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Chickles, Derek"
	<Derek.Chickles@cavium.com>, "Burla, Satananda" <Satananda.Burla@cavium.com>,
	"Manlunas, Felix" <Felix.Manlunas@cavium.com>
Subject: RE: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF support
Thread-Topic: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF
 support
Thread-Index: AQHSKpSaYMBbrDGXMEGcwEvdaGw8oKCxpgoAgAATWJCAABqNAIAAIDSQ
Date: Thu, 20 Oct 2016 23:08:55 +0000
References: <1476942046-18789-2-git-send-email-rvatsavayi@caviumnetworks.com>
	<20161020.141304.286994718471308700.davem@davemloft.net>
	<DM3PR07MB21387F2B6D44558DBC36649881D50@DM3PR07MB2138.namprd07.prod.outlook.com>
 <20161020.165720.1537348879596195765.davem@davemloft.net>
In-Reply-To: <20161020.165720.1537348879596195765.davem@davemloft.net>
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, October 20, 2016 1:57 PM
> To: Vatsavayi, Raghu
> Cc: netdev@vger.kernel.org; Chickles, Derek; Burla, Satananda; Manlunas,
> Felix
> Subject: Re: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF
> support
>=20
> From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
> Date: Thu, 20 Oct 2016 20:01:37 +0000
>=20
> >
> >
> >> -----Original Message-----
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Thursday, October 20, 2016 11:13 AM
> >> To: Vatsavayi, Raghu
> >> Cc: netdev@vger.kernel.org; Vatsavayi, Raghu; Chickles, Derek; Burla,
> >> Satananda; Manlunas, Felix
> >> Subject: Re: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for
> >> VF support
> >>
> >> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
> >> Date: Wed, 19 Oct 2016 22:40:38 -0700
> >>
> >> > +/* Default behaviour of Liquidio is to provide one queue per VF.
> >> > +But Liquidio
> >> > + * can also provide multiple queues to each VF. If user wants to
> >> > +change the
> >> > + * default behaviour HW should be provided configuration info at
> >> > +init time,
> >> > + * based on which it will create control queues for communicating
> >> > +with
> >> FW.
> >> > + */
> >> > +static u32 max_vfs[2] =3D { 0, 0 };
> >> > +module_param_array(max_vfs, int, NULL, 0444);
> >> > +MODULE_PARM_DESC(max_vfs, "Assign two comma-separated
> unsigned
> >> > +integers that specify max number of VFs for PF0 (left of the
> >> > +comma) and PF1 (right of the comma); for 23xx only. By default HW
> >> > +will configure as many VFs as queues after allocating PF queues.To
> >> > +increase queues for VF use this parameter. Use sysfs to create
> >> > +these VFs.");
> >> > +
> >> > +static unsigned int num_queues_per_pf[2] =3D { 0, 0 };
> >> > +module_param_array(num_queues_per_pf, uint, NULL, 0444);
> >> > +MODULE_PARM_DESC(num_queues_per_pf, "two comma-separated
> >> unsigned
> >> > +integers that specify number of queues per PF0 (left of the comma)
> >> > +and PF1 (right of the comma); for 23xx only");
> >> > +
> >> >  static int ptp_enable =3D 1;
> >>
> >> We cannot continue to allow drivers to add custom module parameters
> >> to control this.  It is the worst user experience possible.
> >>
> >> We need a tree-wide generic, consistent, manner in which to configure
> >> and control this kind of thing.
> >
> > Sure Dave, I will remove max_vfs module parameter and will use tree
> > wide generic sysfs interface to enable VFs.
>=20
> That's not what I meant.
>=20
> I mean there needs to be a generic mechanism that isn't a per-device knob
> (be it a module parameter or a sysctl, to me these are identical function=
ality
> and user experience wise).
>=20
> Something like ethtool or netlink.

Dave, I will remove max_vfs module parameter and will just use the generic =
mechanism that all drivers do like:

" echo 10 > /sys/devices/pci0000:00/0000:00:03.0/0000:03:00.1/sriov_numvfs"

Regarding other module parameters, in non-default case if user wants to hav=
e multiple queues then because of the way Liquidio HW works we need num_que=
ues_per_pf and num_queues_per_vf module parameters at HW/module init time. =
This is because in multi-queues per VF scenario, HW has to carve these queu=
es before FW can start communicating with PF/VF host drivers, so we must in=
clude these two parameters.=20

Please confirm that having these two module parameters is fine for non-defa=
ult case. I will soon forward you the patches with these changes that you h=
ave recommended.

Thanks Much
Raghu.

--_002_DM3PR07MB21386FE887D71590E16ED59B81AE0DM3PR07MB2138namp_--

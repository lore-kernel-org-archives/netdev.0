From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] tools: hv: Add clean up for included files in
 Ubuntu net config
Date: Fri, 12 May 2017 18:46:10 +0000
Message-ID: <BLUPR03MB1412D55CDB4088C95D84B204CAE20@BLUPR03MB1412.namprd03.prod.outlook.com>
References: <1494598413-19106-1-git-send-email-haiyangz@exchange.microsoft.com>
 <20170512.122026.71874509847193117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        KY Srinivasan <kys@microsoft.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
        "vkuznets@redhat.com" <vkuznets@redhat.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170512.122026.71874509847193117.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, May 12, 2017 12:20 PM
> To: Haiyang Zhang <haiyangz@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>
> Cc: netdev@vger.kernel.org; KY Srinivasan <kys@microsoft.com>;
> olaf@aepfle.de; vkuznets@redhat.com; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next] tools: hv: Add clean up for included files
> in Ubuntu net config
>=20
> From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
> Date: Fri, 12 May 2017 07:13:33 -0700
>=20
> >
> > +	local fn
> > +	for fn in "${fnlist[@]}"
> > +	do
> >  	awk "/$nic_end/{x=3D0} x{next} /$nic_start/{x=3D1;next} 1"
> $fn >$tmpfl
> >
> >  	cp $tmpfl $fn
> > +	done
>=20
> Please indent the body of this loop properly.

Will do. Thanks.

From: "Kershner, David A" <David.Kershner@unisys.com>
Subject: RE: [PATCH net-next v2 6/9] net: use core MTU range checking in virt
 drivers
Date: Thu, 20 Oct 2016 20:12:38 +0000
Message-ID: <SN1PR0701MB1838454F38F431F3216AEB42F0D50@SN1PR0701MB1838.namprd07.prod.outlook.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
 <20161020175524.6184-7-jarod@redhat.com>
 <BLUPR03MB141270CC6037546F918409AECAD50@BLUPR03MB1412.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "virtualization@lists.linux-foundation.org"
        <virtualization@lists.linux-foundation.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>,
        Wei Liu <wei.liu2@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>
To: Haiyang Zhang <haiyangz@microsoft.com>,
        Jarod Wilson <jarod@redhat.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BLUPR03MB141270CC6037546F918409AECAD50@BLUPR03MB1412.namprd03.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Haiyang Zhang [mailto:haiyangz@microsoft.com]
> Sent: Thursday, October 20, 2016 2:05 PM
> To: Jarod Wilson <jarod@redhat.com>; linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org; virtualization@lists.linux-foundation.org; KY
> Srinivasan <kys@microsoft.com>; Michael S. Tsirkin <mst@redhat.com>;
> Shrikrishna Khare <skhare@vmware.com>; VMware, Inc. <pv-
> drivers@vmware.com>; Wei Liu <wei.liu2@citrix.com>; Paul Durrant
> <paul.durrant@citrix.com>; Kershner, David A
> <David.Kershner@unisys.com>
> Subject: RE: [PATCH net-next v2 6/9] net: use core MTU range checking in =
virt
> drivers
>=20
>=20
>=20
> > -----Original Message-----
> > From: Jarod Wilson [mailto:jarod@redhat.com]
> > Sent: Thursday, October 20, 2016 1:55 PM
> > To: linux-kernel@vger.kernel.org
> > Cc: Jarod Wilson <jarod@redhat.com>; netdev@vger.kernel.org;
> > virtualization@lists.linux-foundation.org; KY Srinivasan
> > <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
> Michael S.
> > Tsirkin <mst@redhat.com>; Shrikrishna Khare <skhare@vmware.com>;
> VMware,
> > Inc. <pv-drivers@vmware.com>; Wei Liu <wei.liu2@citrix.com>; Paul
> > Durrant <paul.durrant@citrix.com>; David Kershner
> > <david.kershner@unisys.com>
> > Subject: [PATCH net-next v2 6/9] net: use core MTU range checking in
> > virt drivers
> >
> > hyperv_net:
> > - set min/max_mtu, per Haiyang, after rndis_filter_device_add
> >
> > virtio_net:
> > - set min/max_mtu
> > - remove virtnet_change_mtu
> >
> > vmxnet3:
> > - set min/max_mtu
> >
> > xen-netback:
> > - min_mtu =3D 0, max_mtu =3D 65517
> >
> > xen-netfront:
> > - min_mtu =3D 0, max_mtu =3D 65535
> >
> > unisys/visor:
> > - clean up defines a little to not clash with network core or add
> >   redundat definitions
> >
> > CC: netdev@vger.kernel.org
> > CC: virtualization@lists.linux-foundation.org
> > CC: "K. Y. Srinivasan" <kys@microsoft.com>
> > CC: Haiyang Zhang <haiyangz@microsoft.com>
> > CC: "Michael S. Tsirkin" <mst@redhat.com>
> > CC: Shrikrishna Khare <skhare@vmware.com>
> > CC: "VMware, Inc." <pv-drivers@vmware.com>
> > CC: Wei Liu <wei.liu2@citrix.com>
> > CC: Paul Durrant <paul.durrant@citrix.com>
> > CC: David Kershner <david.kershner@unisys.com>
> > Signed-off-by: Jarod Wilson <jarod@redhat.com>
> > ---
>=20
> The hv_netvsc changes look fine. Thanks.
>=20
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
>=20

The visornic changes look good.

Reviewed-by: David Kershner <david.kershner@unisys.com>


=20

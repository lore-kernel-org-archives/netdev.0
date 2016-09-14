From: Adit Ranadive <aditr@vmware.com>
Subject: Re: [PATCH v4 01/16] vmxnet3: Move PCI Id to pci_ids.h
Date: Wed, 14 Sep 2016 19:36:34 +0000
Message-ID: <DM2PR0501MB84422A1029EE72FC727F960C5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-2-git-send-email-aditr@vmware.com>
 <20160914110854.GA15800@yuval-lap.uk.oracle.com>
 <DM2PR0501MB844852987661859C6654E40C5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
 <20160914162452.GA3216@yuval-lap.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-002.vmware.com ([208.91.0.190]:51185 "EHLO
        EX13-EDG-OU-002.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761984AbcINTgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 15:36:46 -0400
In-Reply-To: <20160914162452.GA3216@yuval-lap.Home>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 09:25:18 -0700, Yuval Shaia wrote:
> On Wed, Sep 14, 2016 at 04:00:25PM +0000, Adit Ranadive wrote:
> > On Wed, Sep 14, 2016 at 04:09:12 -0700, Yuval Shaia wrote:
> > > Please update vmxnet3_drv.c accordingly.
> >
> > Any reason why? I don't think we need to. Vmxnet3 should just pick up
> > the moved PCI device id from pci_ids.h file.
>=20
> So now you need to include it from vmxnet3_drv.c.
> Same with pvrdma_main.c

If you're asking me to include pci_ids.h in our drivers we already do that
by including pci.h in both the drivers.=20
pci.h already includes pci_ids.h -=20
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/includ=
e/linux/pci.h#n35

If that's going to change maybe someone from the PCI group can comment on.

Thanks,
Adit

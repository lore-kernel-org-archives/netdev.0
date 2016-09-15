From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH v4 01/16] vmxnet3: Move PCI Id to pci_ids.h
Date: Thu, 15 Sep 2016 10:55:26 +0300
Message-ID: <20160915075525.GB3851@yuval-lap.uk.oracle.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-2-git-send-email-aditr@vmware.com>
 <20160914110854.GA15800@yuval-lap.uk.oracle.com>
 <DM2PR0501MB844852987661859C6654E40C5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
 <20160914162452.GA3216@yuval-lap.Home>
 <DM2PR0501MB84422A1029EE72FC727F960C5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: Adit Ranadive <aditr@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <DM2PR0501MB84422A1029EE72FC727F960C5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Besides that no more comments.

Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>

On Wed, Sep 14, 2016 at 07:36:34PM +0000, Adit Ranadive wrote:
> On Wed, Sep 14, 2016 at 09:25:18 -0700, Yuval Shaia wrote:
> > On Wed, Sep 14, 2016 at 04:00:25PM +0000, Adit Ranadive wrote:
> > > On Wed, Sep 14, 2016 at 04:09:12 -0700, Yuval Shaia wrote:
> > > > Please update vmxnet3_drv.c accordingly.
> > >
> > > Any reason why? I don't think we need to. Vmxnet3 should just pick up
> > > the moved PCI device id from pci_ids.h file.
> > 
> > So now you need to include it from vmxnet3_drv.c.
> > Same with pvrdma_main.c
> 
> If you're asking me to include pci_ids.h in our drivers we already do that
> by including pci.h in both the drivers. 
> pci.h already includes pci_ids.h - 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/linux/pci.h#n35
> 
> If that's going to change maybe someone from the PCI group can comment on.
> 
> Thanks,
> Adit
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

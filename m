From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 00/16] Add Paravirtual RDMA Driver
Date: Wed, 14 Sep 2016 14:50:20 -0600
Message-ID: <20160914205020.GB14548@obsidianresearch.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <20160912180251.GH5843@obsidianresearch.com>
 <BLUPR0501MB836ED564F2AE7AB9221AC25C5FF0@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160914173636.GA10309@obsidianresearch.com>
 <DM2PR0501MB844473AE0FCAD0FD748D43DC5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
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
In-Reply-To: <DM2PR0501MB844473AE0FCAD0FD748D43DC5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 07:44:45PM +0000, Adit Ranadive wrote:
> On Wed, Sep 14, 2016 at 10:37:00 -0700, Jason Gunthorpe wrote:
> > We desire to use this as the vehical for the userspace included with the 4.9
> > kernel.
> > 
> > I anticipate the tree will be running by Oct 1.
> 
> Thanks. So does this mean that the libraries distributed via OFED (openfabrics.org)
> will be now from the rdma-plumbing git tree?

I can't speak to the exact transition schedule each downstream will
follow. OFED is a downstream distribution focused on backporting to
old distros.

I would expect that by the time OFED starts to backport 4.9 they will
need to use rdma plumbing.

At the cutoff point we will immediately tell all downstreams the
latest official upstream source is in rdma-plumbing and they should
stop monitoring the old repos.

> Or is the switch to happen only when distros start shipping with the
> 4.9 kernel by default?

Now that we are going down this path with the 4.9 set as the time
frame, I wouldn't worry about timing, there is no down-side to you for
working within rdma-plumbing, and it guarantees that eventually your
code will be widely distributed.

Jason

From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 00/16] Add Paravirtual RDMA Driver
Date: Wed, 14 Sep 2016 16:59:10 -0600
Message-ID: <20160914225910.GB3567@obsidianresearch.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <20160912180251.GH5843@obsidianresearch.com>
 <BLUPR0501MB836ED564F2AE7AB9221AC25C5FF0@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160914173636.GA10309@obsidianresearch.com>
 <DM2PR0501MB844473AE0FCAD0FD748D43DC5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
 <9C6B67F36DCAFC479B1CF6A967258A8C7DE14CE8@ORSMSX115.amr.corp.intel.com>
 <9C6B67F36DCAFC479B1CF6A967258A8C7DE14D3E@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        pv-drivers <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Jorgen S. Hansen" <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        Aditya Sarwade <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        George Zhang <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        Bryan Tan <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
To: "Woodruff, Robert J" <robert.j.woodruff-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9C6B67F36DCAFC479B1CF6A967258A8C7DE14D3E-8oqHQFITsIFqS6EAlXoojrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 10:20:22PM +0000, Woodruff, Robert J wrote:

> >this new scheme works with >kernel.org 4.8, then it is possible
> >that it could go into that OFED-4.8 Release, but again, we are
> >still looking at the new scheme and evaluating how it affects >the
> >community OFED.
> 
> One other question.  Jason, the OFA (and its members) want to
> maintain the dual-license (BSD/GPL) for the code, as is the case for
> all the code that was in the OFA git trees on the OFA server that
> you pulled from.

The code in the OFA trees has a mixture of licenses. It is all GPLv2
compatible for sure, but there are at least three variations of the
'BSD' license. As far as I know, only the 2 clause OpenIB.org BSD
license is approved for use in OFA projects. Someone from the board
could correct me if I am wrong.

This means the 3 projects with the BSD patent clause, hosted on the
OFA servers, were already not conforming.

As is Intels HFI1 driver which uses a three clause BSD license.

> package follows that licensing model for accepting any new code into
> that combined repo ?

As with the kernel we'd discourage 're-licensing' existing files.

However, since this is not a OFA project, I, personally, would not
turn away a GPLv2 compatible contribution, but I am proposing that the
'default' license for the project be OFA compatible.

I think license enforcement of its members falls to the OFA.

Doug may feel differently.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Adit Ranadive <aditr@vmware.com>
Subject: Re: [PATCH v5 00/16] Add Paravirtual RDMA Driver
Date: Mon, 26 Sep 2016 13:40:10 -0700
Message-ID: <b4e0acd9-e1a2-f6ac-0afa-c0fd62dd62f0@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
 <20160925070352.GU4088@leon.nu>
 <9f65ab5c-d8c2-e8e3-9334-5d1865a20dc9@vmware.com>
 <20160926165104.GA12011@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Leon Romanovsky <leon@kernel.org>, <dledford@redhat.com>,
        <linux-rdma@vger.kernel.org>, <pv-drivers@vmware.com>,
        <netdev@vger.kernel.org>, <linux-pci@vger.kernel.org>,
        <jhansen@vmware.com>, <asarwade@vmware.com>,
        <georgezhang@vmware.com>, <bryantan@vmware.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-002.vmware.com ([208.91.0.190]:37126 "EHLO
        EX13-EDG-OU-002.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933488AbcIZUoO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 16:44:14 -0400
In-Reply-To: <20160926165104.GA12011@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2016 at 10:51:04AM -0600, Jason Gunthorpe wrote:
> On Sun, Sep 25, 2016 at 10:25:12PM -0700, Adit Ranadive wrote:
> > > As Jason said, you need a very good reason to split and create number of
> > > files per-driver in UAPI folder.
> > 
> > I can move the pvrdma-uapi.h back to the pvrdma driver folder.
> 
> Just don't copy any of the content into your user space provider.

Thanks. I wanted to clarify regarding device specific structures since that
is what our pvrdma-uapi.h file has.

Wouldnt they be some overlap between the user-space and kernel driver? Or is
it expected that the common structures (even device specific ones) be moved to
the ABI file?

For the mlx4 driver I see that the structures in include/linux/mlx4/qp.h
and in libmlx4/src/wqe.h are similar.

Thanks,
Adit

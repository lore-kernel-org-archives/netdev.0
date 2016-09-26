From: Adit Ranadive <aditr@vmware.com>
Subject: Re: [PATCH v5 13/16] IB/pvrdma: Add the main driver module for PVRDMA
Date: Mon, 26 Sep 2016 11:15:28 -0700
Message-ID: <651b18ee-55ca-0c72-af9c-c55c42b57fd1@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
 <8db982c37a0a96b37df02826564474a216922f25.1474759181.git.aditr@vmware.com>
 <20160926072739.GB6352@yuval-lap.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:12171 "EHLO
        EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1161935AbcIZSSv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 14:18:51 -0400
In-Reply-To: <20160926072739.GB6352@yuval-lap.Home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2016 at 00:27:40AM -0700, Yuval Shaia wrote:
> On Sat, Sep 24, 2016 at 04:21:37PM -0700, Adit Ranadive wrote:
> > +
> > +	/* Currently, the driver only supports RoCE mode. */
> > +	if (dev->dsr->caps.mode != PVRDMA_DEVICE_MODE_ROCE) {
> > +		dev_err(&pdev->dev, "unsupported transport %d\n",
> > +			dev->dsr->caps.mode);
> > +		ret = -EINVAL;
> 
> This is some fatal error with the device, not that something wrong with the
> function's argument.
> Suggesting to replace with -EFAULT.
> 

Thanks, will fix this one and the others here.

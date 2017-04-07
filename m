From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mlxsw: convert to pci_alloc_irq_vectors
Date: Fri, 07 Apr 2017 07:14:05 -0700 (PDT)
Message-ID: <20170407.071405.627036901988213530.davem@davemloft.net>
References: <20170406122303.30758-1-hch@lst.de>
        <20170406124320.GA5456@splinter.mtl.com>
        <20170407130808.GA31087@splinter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, jiri@mellanox.com, idosch@mellanox.com,
        netdev@vger.kernel.org
To: idosch@idosch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54274 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752433AbdDGOOK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 10:14:10 -0400
In-Reply-To: <20170407130808.GA31087@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@idosch.org>
Date: Fri, 7 Apr 2017 16:08:08 +0300

> Hi Dave,
> 
> On Thu, Apr 06, 2017 at 03:43:20PM +0300, Ido Schimmel wrote:
>> On Thu, Apr 06, 2017 at 02:23:03PM +0200, Christoph Hellwig wrote:
>> > Trivial conversion as only one vector is supported, but at least we
>> > lose the useless msix_entry member in the per-device structure.
>> > 
>> > Signed-off-by: Christoph Hellwig <hch@lst.de>
>> 
>> For net-next:
> 
> I noticed this is marked as "Not Applicable" in patchwork:
> https://patchwork.ozlabs.org/patch/747723/
> 
> But I'm not quite sure why. Maybe you meant to mark only v1?
> https://patchwork.ozlabs.org/patch/747674/

If the last patch of his series removes a kernel global API,
it shouldn't go via my tree.  He can send it directly to Linus
or via the PCI maintainer.

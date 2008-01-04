From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Fri, 4 Jan 2008 11:23:41 +0100
Message-ID: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com>
References: <20071222233056.d652743e.akpm@linux-foundation.org>
	 <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com>
	 <20071228150746.42b3bbc0.akpm@linux-foundation.org>
	 <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com>
	 <20071230013021.GA13603@gondor.apana.org.au>
	 <64bb37e0712291934o77a3d365h56c9c31ac8437469@mail.gmail.com>
	 <64bb37e0712311215x519b10e9kd51eb745b3b7290a@mail.gmail.com>
	 <20080101120406.GA27209@gondor.apana.org.au>
	 <64bb37e0801021029u1735bb9eta53906b123abf577@mail.gmail.com>
	 <20080102215154.GA13911@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	"Tom Tucker" <tom@opengridcomputing.com>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:55716 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbYADKXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 05:23:45 -0500
Received: by py-out-1112.google.com with SMTP id u52so11000179pyb.10
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2008 02:23:42 -0800 (PST)
In-Reply-To: <20080102215154.GA13911@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 2, 2008 10:51 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, Jan 02, 2008 at 07:29:59PM +0100, Torsten Kaiser wrote:
> >
> > Vanilla 2.6.24-rc6 seems stable. I did not see any crash or warnings.
>
> OK that's great.  The next step would be to try excluding specific git
> trees from mm to see if they make a difference.
>
> The two specific trees of interest would be git-nfsd and git-net.

git-nfsd from git://git.linux-nfs.org/projects/bfields/linux.git#for-mm
-> compiling and installing 54 packages worked without crashes.

git-net from git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git
-> compiling and installing 95 packages worked without crashes.

The only thing in the announces of 2.6.24-rc3-mm1/2 that stands out for me is:
+iommu-sg-merging-add-device_dma_parameters-structure.patch
+iommu-sg-merging-pci-add-device_dma_parameters-support.patch
+iommu-sg-merging-x86-make-pci-gart-iommu-respect-the-segment-size-limits.patch
+iommu-sg-merging-ppc-make-iommu-respect-the-segment-size-limits.patch
+iommu-sg-merging-ia64-make-sba_iommu-respect-the-segment-size-limits.patch
+iommu-sg-merging-alpha-make-pci_iommu-respect-the-segment-size-limits.patch
+iommu-sg-merging-sparc64-make-iommu-respect-the-segment-size-limits.patch
+iommu-sg-merging-parisc-make-iommu-respect-the-segment-size-limits.patch
+iommu-sg-merging-call-blk_queue_segment_boundary-in-__scsi_alloc_queue.patch
+iommu-sg-merging-sata_inic162x-use-pci_set_dma_max_seg_size.patch
+iommu-sg-merging-aacraid-use-pci_set_dma_max_seg_size.patch

 iommu work

I will enable CONFIG_IOMMU_DEBUG in -rc6-mm1 and see, as otherwise I
have no clue where to look...

Torsten

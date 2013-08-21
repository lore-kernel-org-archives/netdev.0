From: Andy King <acking@vmware.com>
Subject: Re: [PATCH] VMXNET3: Add support for virtual IOMMU
Date: Wed, 21 Aug 2013 06:37:34 -0700 (PDT)
Message-ID: <1944820276.33601674.1377092254160.JavaMail.root@vmware.com>
References: <1377020012-1839-1-git-send-email-acking@vmware.com>
	<20130821.000255.1258155583733908892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130821.000255.1258155583733908892.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Adding Greg, since this will apply to a similar patchset I sent out
for VMCI.

----- Original Message -----
> From: Andy King <acking@vmware.com>
> Date: Tue, 20 Aug 2013 10:33:32 -0700
> 
> > We can't just do virt_to_phys() on memory that we pass to the device and
> > expect it to work in presence of a virtual IOMMU.  We need to add IOMMU
> > mappings for such DMAs to work correctly.  Fix that with
> > pci_alloc_consistent() where possible, or pci_map_single() where the
> > mapping is short-lived or we don't control the allocation (netdev).
>
> Please use dma_alloc_coherent() (or in fact dma_zalloc_coherent()),
> dma_map_single() et al., because they are preferred and in particular
> allow specification of GFP_* flags

Sorry about that, I'll fix that and send out a new patch.

Thanks!
- Andy

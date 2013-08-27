From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VMXNET3: Add support for virtual IOMMU
Date: Tue, 27 Aug 2013 16:02:26 -0400 (EDT)
Message-ID: <20130827.160226.1047540632131698779.davem@davemloft.net>
References: <1377275629-14587-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: acking@vmware.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1377275629-14587-1-git-send-email-acking@vmware.com>
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

From: Andy King <acking@vmware.com>
Date: Fri, 23 Aug 2013 09:33:49 -0700

> This patch adds support for virtual IOMMU to the vmxnet3 module.  We
> switch to DMA consistent mappings for anything we pass to the device.
> There were a few places where we already did this, but using pci_blah();
> these have been fixed to use dma_blah(), along with all new occurrences
> where we've replaced kmalloc() and friends.
> 
> Also fix two small bugs:
> 1) use after free of rq->buf_info in vmxnet3_rq_destroy()
> 2) a cpu_to_le32() that should have been a cpu_to_le64()
> 
> Acked-by: George Zhang <georgezhang@vmware.com>
> Acked-by: Aditya Sarwade <asarwade@vmware.com>
> Signed-off-by: Andy King <acking@vmware.com>

Applied, thanks.

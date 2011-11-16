From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next v2] enable virtio_net to return bus_info
	in ethtool -i consistent with emulated NICs
Date: Wed, 16 Nov 2011 17:27:02 -0500 (EST)
Message-ID: <20111116.172702.1492694683492850340.davem@davemloft.net>
References: <20111115001708.72ED0290054F@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mst@redhat.com
To: raj@tardy.cup.hp.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111115001708.72ED0290054F@tardy>
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

From: raj@tardy.cup.hp.com (Rick Jones)
Date: Mon, 14 Nov 2011 16:17:08 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> Add a new .bus_name to virtio_config_ops then modify virtio_net to 
> call through to it in an ethtool .get_drvinfo routine to report
> bus_info in ethtool -i output which is consistent with other
> emulated NICs and the output of lspci.  
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> ---
> 
> The changes to drivers/lguest/lguest_device.c, drivers/s390/kvm/kvm_virtio.c,
> and drivers/virtio/virtio_mmio.c code inspected only, not compiled.

Applied, thanks Rick.

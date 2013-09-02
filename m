From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: Set RXCSUM feature if GUEST_CSUM is available
Date: Mon, 02 Sep 2013 11:17:57 +0930
Message-ID: <87ioyk9epe.fsf@rustcorp.com.au>
References: <1377616142-29590-1-git-send-email-thuth@linux.vnet.ibm.com>
	<20130829.155704.248095796202059854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>, thuth@linux.vnet.ibm.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130829.155704.248095796202059854.davem@davemloft.net>
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

David Miller <davem@davemloft.net> writes:
> From: Thomas Huth <thuth@linux.vnet.ibm.com>
> Date: Tue, 27 Aug 2013 17:09:02 +0200
>
>> If the VIRTIO_NET_F_GUEST_CSUM virtio feature is available, the guest
>> does not have to calculate the checksums on all received packets. This
>> is pretty much the same feature as RX checksum offloading on real
>> network cards, so the virtio-net driver should report this by setting
>> the NETIF_F_RXCSUM flag. When the user now runs "ethtool -k", he or she
>> can see whether the virtio-net interface has to calculate RX checksums
>> or not.
>> 
>> Signed-off-by: Thomas Huth <thuth@linux.vnet.ibm.com>
>
> Can one of the virtio_net folks please review this?

Hmm, so NETIF_F_RXCSUM only exists for ethtool's benefit.  Weird.

But this patch is correct:

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.

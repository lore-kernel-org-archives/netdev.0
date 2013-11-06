From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net-next] virtio-net: switch to use XPS to
	choose txq
Date: Tue, 05 Nov 2013 22:22:03 -0500 (EST)
Message-ID: <20131105.222203.740870236265138632.davem@davemloft.net>
References: <1383646785-10446-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1383646785-10446-1-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Tue,  5 Nov 2013 18:19:45 +0800

> We used to use a percpu structure vq_index to record the cpu to queue
> mapping, this is suboptimal since it duplicates the work of XPS and
> loses all other XPS functionality such as allowing user to configure
> their own transmission steering strategy.
> 
> So this patch switches to use XPS and suggest a default mapping when
> the number of cpus is equal to the number of queues. With XPS support,
> there's no need for keeping per-cpu vq_index and .ndo_select_queue(),
> so they were removed also.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> Resend since the previous complie warning disappears after commit
> 3573540cafa4296dd60f8be02f2aecaa31047525
> (netif_set_xps_queue: make cpu mask const).

Yep, looks great, applied.  Thanks Jason!

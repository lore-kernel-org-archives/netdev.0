From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH v1 1/2] virtio_net: Pass gfp flags when allocating rx
	buffers.
Date: Thu, 05 Jan 2012 10:40:02 +1030
Message-ID: <871urfc8md.fsf@rustcorp.com.au>
References: <20120104225223.18184.1537.stgit@mike2.sea.corp.google.com>
	<20120104225231.18184.96390.stgit@mike2.sea.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Mike Waychison <mikew@google.com>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120104225231.18184.96390.stgit@mike2.sea.corp.google.com>
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

On Wed, 04 Jan 2012 14:52:32 -0800, Mike Waychison <mikew@google.com> wrote:
> Currently, the refill path for RX buffers will always allocate the
> buffers as GFP_ATOMIC, even if we are in process context.  This will
> fail to apply memory pressure as the worker thread will not contribute
> to the freeing of memory.
> 
> Fix this by changing add_recvbuf_small to use the gfp variant allocator,
> __netdev_alloc_skb_ip_align().
> 
> Signed-off-by: Mike Waychison <mikew@google.com>

OK, this is a no-brainer.  Thanks!  Dave, can you pick this up?

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Cheers,
Rusty.

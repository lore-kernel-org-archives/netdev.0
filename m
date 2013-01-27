From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V8 1/3] virtio-net: fix the set affinity bug when CPU
	IDs are not consecutive
Date: Sun, 27 Jan 2013 01:23:56 -0500 (EST)
Message-ID: <20130127.012356.186129078703210985.davem@davemloft.net>
References: <1359107491-6749-1-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, erdnetdev@gmail.com
To: gaowanlong@cn.fujitsu.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1359107491-6749-1-git-send-email-gaowanlong@cn.fujitsu.com>
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

From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Date: Fri, 25 Jan 2013 17:51:29 +0800

> As Michael mentioned, set affinity and select queue will not work very
> well when CPU IDs are not consecutive, this can happen with hot unplug.
> Fix this bug by traversal the online CPUs, and create a per cpu variable
> to find the mapping from CPU to the preferable virtual-queue.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Eric Dumazet <erdnetdev@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: virtualization@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied.

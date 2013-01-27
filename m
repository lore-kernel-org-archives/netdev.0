From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V8 3/3] virtio-net: reset virtqueue affinity when doing
	cpu hotplug
Date: Sun, 27 Jan 2013 01:24:11 -0500 (EST)
Message-ID: <20130127.012411.1639876926107470174.davem@davemloft.net>
References: <1359107491-6749-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<1359107491-6749-3-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, erdnetdev@gmail.com
To: gaowanlong@cn.fujitsu.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1359107491-6749-3-git-send-email-gaowanlong@cn.fujitsu.com>
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
Date: Fri, 25 Jan 2013 17:51:31 +0800

> Add a cpu notifier to virtio-net, so that we can reset the
> virtqueue affinity if the cpu hotplug happens. It improve
> the performance through enabling or disabling the virtqueue
> affinity after doing cpu hotplug.
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

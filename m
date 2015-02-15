From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vhost_net: fix wrong iter offset when setting
	number of buffers
Date: Sun, 15 Feb 2015 08:17:53 -0800 (PST)
Message-ID: <20150215.081753.375314410062222400.davem@davemloft.net>
References: <1423989317-16038-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	viro@zeniv.linux.org.uk
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1423989317-16038-1-git-send-email-jasowang@redhat.com>
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
Date: Sun, 15 Feb 2015 16:35:17 +0800

> In commit ba7438aed924 ("vhost: don't bother copying iovecs in
> handle_rx(), kill memcpy_toiovecend()"), we advance iov iter fixup
> sizeof(struct virtio_net_hdr) bytes and fill the number of buffers
> after doing the socket recvmsg(). This work well but was broken after
> commit 6e03f896b52c ("Merge
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net") which tries
> to advance sizeof(struct virtio_net_hdr_mrg_rxbuf). It will fill the
> number of buffers at the wrong place. This patch fixes this.
> 
> Fixes 6e03f896b52c
> ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I was wondering if I got that merge conflict right. :-/

Applied, thanks Jason.

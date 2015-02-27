From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: cleanup iterator update logic
Date: Fri, 27 Feb 2015 15:58:45 -0500 (EST)
Message-ID: <20150227.155845.171916200094175034.davem@davemloft.net>
References: <1424795477-6820-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1424795477-6820-1-git-send-email-mst@redhat.com>
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

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 24 Feb 2015 17:31:31 +0100

> Recent iterator-related changes in vhost made it
> harder to follow the logic fixing up the header.
> In fact, the fixup always happens at the same
> offset: sizeof(virtio_net_hdr): sometimes the
> fixup iterator is updated by copy_to_iter,
> sometimes-by iov_iter_advance.
> 
> Rearrange code to make this obvious.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied.

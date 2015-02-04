From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for-3.19] vhost/net: fix up num_buffers endian-ness
Date: Wed, 04 Feb 2015 13:59:42 -0800 (PST)
Message-ID: <20150204.135942.127858058517785730.davem@davemloft.net>
References: <1422896842-19186-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, viro@ZenIV.linux.org.uk
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1422896842-19186-1-git-send-email-mst@redhat.com>
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
Date: Tue, 3 Feb 2015 11:07:06 +0200

> In virtio 1.0 mode, when mergeable buffers are enabled on a big-endian
> host, num_buffers wasn't byte-swapped correctly, so large incoming
> packets got corrupted.
> 
> To fix, fill it in within hdr - this also makes sure it gets
> the correct type.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied.

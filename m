From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] virtio-net: determine type of bufs correctly
Date: Fri, 06 Dec 2013 15:30:44 -0500 (EST)
Message-ID: <20131206.153044.1353870753889298332.davem@davemloft.net>
References: <1386254181-17257-1-git-send-email-avagin@openvz.org>
	<1386254181-17257-2-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: avagin@openvz.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1386254181-17257-2-git-send-email-avagin@openvz.org>
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

From: Andrey Vagin <avagin@openvz.org>
Date: Thu,  5 Dec 2013 18:36:20 +0400

> free_unused_bufs must check vi->mergeable_rx_bufs before
> vi->big_packets, because we use this sequence in other places.
> Otherwise we allocate buffer of one type, then free it as another
> type.
 ...
> Fixes: 2613af0ed18a (virtio_net: migrate mergeable rx buffers to page frag allocators)
> Cc: Michael Dalton <mwdalton@google.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied.

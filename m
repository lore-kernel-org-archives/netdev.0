From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] virtio: delete napi structures from netdev before
	releasing memory
Date: Fri, 06 Dec 2013 15:30:58 -0500 (EST)
Message-ID: <20131206.153058.1741013299538900621.davem@davemloft.net>
References: <1386254181-17257-1-git-send-email-avagin@openvz.org>
	<1386254181-17257-3-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: avagin@openvz.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1386254181-17257-3-git-send-email-avagin@openvz.org>
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
Date: Thu,  5 Dec 2013 18:36:21 +0400

> free_netdev calls netif_napi_del too, but it's too late, because napi
> structures are placed on vi->rq. netif_napi_add() is called from
> virtnet_alloc_queues.
 ...
> Fixes: 986a4f4d452d (virtio_net: multiqueue support)
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied and queued up for -stable, thanks.

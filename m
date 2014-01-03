From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: fix refill races during restore
Date: Thu, 02 Jan 2014 19:23:54 -0500 (EST)
Message-ID: <20140102.192354.1248162707820922093.davem@davemloft.net>
References: <1388374480-3872-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, amit.shah@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1388374480-3872-1-git-send-email-jasowang@redhat.com>
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
Date: Mon, 30 Dec 2013 11:34:40 +0800

> During restoring, try_fill_recv() was called with neither napi lock nor napi
> disabled. This can lead two try_fill_recv() was called in the same time. Fix
> this by refilling before trying to enable napi.
> 
> Fixes 0741bcb5584f9e2390ae6261573c4de8314999f2
> (virtio: net: Add freeze, restore handlers to support S4).
> 
> Cc: Amit Shah <amit.shah@redhat.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2 2/2] virtio-net: refill only when device is up
	during setting queues
Date: Thu, 17 Oct 2013 15:55:58 -0400 (EDT)
Message-ID: <20131017.155558.1300032440298974117.davem@davemloft.net>
References: <1381807139-3450-1-git-send-email-jasowang@redhat.com>
	<1381807139-3450-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1381807139-3450-2-git-send-email-jasowang@redhat.com>
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
Date: Tue, 15 Oct 2013 11:18:59 +0800

> We used to schedule the refill work unconditionally after changing the
> number of queues. This may lead an issue if the device is not
> up. Since we only try to cancel the work in ndo_stop(), this may cause
> the refill work still work after removing the device. Fix this by only
> schedule the work when device is up.
> 
> The bug were introduce by commit 9b9cd8024a2882e896c65222aa421d461354e3f2.
> (virtio-net: fix the race between channels setting and refill)
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks Jason.

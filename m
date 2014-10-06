From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/16] virtio_net: drop config_enable
Date: Mon, 06 Oct 2014 15:02:38 -0400 (EDT)
Message-ID: <20141006.150238.2180269239953265506.davem@davemloft.net>
References: <1412525038-15871-1-git-send-email-mst@redhat.com>
	<1412525038-15871-9-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1412525038-15871-9-git-send-email-mst@redhat.com>
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
Date: Sun, 5 Oct 2014 19:07:13 +0300

> Now that virtio core ensures config changes don't arrive during probing,
> drop config_enable flag in virtio net.
> On removal, flush is now sufficient to guarantee that no change work is
> queued.
> 
> This help simplify the driver, and will allow setting DRIVER_OK earlier
> without losing config change notifications.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

It's hard for people on the networking side to review these changes
since you haven't CC:'d them on any of the postings necessary to
understand the context of the net/ and drivers/net/ changes.

Please at a minimum CC: everyone on your header [PATCH 0/N] posting
so we know at least at a high level what is going on, and why.

Thanks.

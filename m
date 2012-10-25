From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH repost for-3.7] vhost: fix mergeable bufs on BE hosts
Date: Wed, 24 Oct 2012 23:20:22 -0400 (EDT)
Message-ID: <20121024.232022.1340389049377129136.davem@davemloft.net>
References: <20121024183751.GC11118@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121024183751.GC11118@redhat.com>
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
Date: Wed, 24 Oct 2012 20:37:51 +0200

> We copy head count to a 16 bit field, this works by chance on LE but on
> BE guest gets 0. Fix it up.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Tested-by: Alexander Graf <agraf@suse.de>
> Cc: stable@vger.kernel.org

Applied, thanks.

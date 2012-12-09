From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] Multiqueue support in virtio-net
Date: Sun, 09 Dec 2012 00:32:19 -0500 (EST)
Message-ID: <20121209.003219.740497965401517120.davem@davemloft.net>
References: <1354899897-10423-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1354899897-10423-1-git-send-email-jasowang@redhat.com>
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
Date: Sat,  8 Dec 2012 01:04:54 +0800

> This series is an update version (hope the final version) of multiqueue
> (VIRTIO_NET_F_MQ) support in virtio-net driver. All previous comments were
> addressed, the work were based on Krishna Kumar's work to let virtio-net use
> multiple rx/tx queues to do the packets reception and transmission. Performance
> test show the aggregate latency were increased greately but may get some
> regression in small packet transmission. Due to this, multiqueue were disabled
> by default. If user want to benefit form the multiqueue, ethtool -L could be
> used to enable the feature.

These changes look fine to me, applied, thanks.

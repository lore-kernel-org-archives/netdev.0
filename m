From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/5] Refine virtio-net XDP
Date: Mon, 24 Jul 2017 13:38:59 -0700 (PDT)
Message-ID: <20170724.133859.192337723544942743.davem@davemloft.net>
References: <1500454489-16805-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1500454489-16805-1-git-send-email-jasowang@redhat.com>
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
Date: Wed, 19 Jul 2017 16:54:44 +0800

> Hi:
> 
> This series brings two optimizations for virtio-net XDP:
> 
> - avoid reset during XDP set
> - turn off offloads on demand
> 
> Changes from V1:
> - Various tweaks on commit logs and comments
> - Use virtnet_napi_enable() when enabling NAPI on XDP set
> - Copy the small buffer packet only if xdp_headroom is smaller than
>   required
> 
> Please review.

Series applied, thanks Jason.

Michael, I gave you 4+ days to properly review this respin of this
series.  I felt that was more than sufficient time, even with an
intervening weekend.  So if you don't like that I applied this without
your review, please be more punctual in the future.

Thank you.

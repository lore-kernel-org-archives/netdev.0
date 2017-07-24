From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next V2 0/5] Refine virtio-net XDP
Date: Tue, 25 Jul 2017 00:41:06 +0300
Message-ID: <20170725000830-mutt-send-email-mst@kernel.org>
References: <1500454489-16805-1-git-send-email-jasowang@redhat.com>
	<20170724.133859.192337723544942743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170724.133859.192337723544942743.davem@davemloft.net>
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

On Mon, Jul 24, 2017 at 01:38:59PM -0700, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Wed, 19 Jul 2017 16:54:44 +0800
> 
> > Hi:
> > 
> > This series brings two optimizations for virtio-net XDP:
> > 
> > - avoid reset during XDP set
> > - turn off offloads on demand
> > 
> > Changes from V1:
> > - Various tweaks on commit logs and comments
> > - Use virtnet_napi_enable() when enabling NAPI on XDP set
> > - Copy the small buffer packet only if xdp_headroom is smaller than
> >   required
> > 
> > Please review.
> 
> Series applied, thanks Jason.
> 
> Michael, I gave you 4+ days to properly review this respin of this
> series.  I felt that was more than sufficient time, even with an
> intervening weekend.  So if you don't like that I applied this without
> your review, please be more punctual in the future.
> 
> Thank you.

My bad - reviewed when I was offline and forgot to send it out.

By luck this is not a big deal:

- Patches 1-4 are good.
- Patch 5 has some problems IMO, but all it does
is try to enable a previously non-working configuration, so
it seems ok to fix it up with follow-up patches as appropriate.

-- 
MST

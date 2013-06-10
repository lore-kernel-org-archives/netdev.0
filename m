From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/2] fix kernel crash with macvtap on top of LRO
Date: Mon, 10 Jun 2013 10:07:11 +0300
Message-ID: <20130610070710.GA673@redhat.com>
References: <1360193660.32217.39.camel@deadeye.wl.decadent.org.uk>
	<1360207111.28557.47.camel@edumazet-glaptop>
	<1360254046.3605.8.camel@bwh-desktop.uk.solarflarecom.com>
	<20130207.131420.1211188723341167971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130207.131420.1211188723341167971.davem@davemloft.net>
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

On Thu, Feb 07, 2013 at 01:14:20PM -0500, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 7 Feb 2013 16:20:46 +0000
> 
> > If the consensus is still that we must preserve packets exactly (aside
> > from the usual modifications by IP routers) then LRO should be disabled
> > on all devices for which forwarding is enabled.
> 
> I believe this is still undoubtedly the consensus.

With virtio we are getting packets from a linux host,
so we could thinkably preserve packets exactly
even with LRO. I am guessing other hardware could be
doing this as well.

I am not sure what information would need to be preserved -
could someone help clarify please?

-- 
MST

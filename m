From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/2] drivers/net,ipv6: Fix IPv6 fragment ID
	selection for virtio
Date: Thu, 30 Oct 2014 20:02:04 -0400 (EDT)
Message-ID: <20141030.200204.1241966215662909080.davem@davemloft.net>
References: <1414693592.16849.61.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	virtualization@lists.linux-foundation.org
To: ben@decadent.org.uk
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414693592.16849.61.camel@decadent.org.uk>
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

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 30 Oct 2014 18:26:32 +0000

> The virtio net protocol supports UFO but does not provide for passing a
> fragment ID for fragmentation of IPv6 packets.  We used to generate a
> fragment ID wherever such a packet was fragmented, but currently we
> always use ID=0!
> 
> v2: Add blank lines after declarations

Series applied and queued up for -stable, thanks Ben.

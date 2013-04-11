From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mv643xx_eth: Add GRO support
Date: Thu, 11 Apr 2013 19:51:47 +0200
Message-ID: <20130411175147.GN1910@1wt.eu>
References: <CABJ1b_TQDabT1J7ffo5cb1Th=71bcSduifMJaDpfVRiiHvtWDw@mail.gmail.com>
 <20130411150326.GA19978@1wt.eu>
 <CABJ1b_TRxm97DKJLP_h0VwMJvcYmSpjoJvtg1KvBNGah=VzqMQ@mail.gmail.com>
 <20130411.133119.913809939413807690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, jason@lakedaemon.net, benh@kernel.crashing.org,
 linux-kernel@vger.kernel.org, smoch@web.de, paulus@samba.org,
 linux-arm-kernel@lists.infradead.org, dale@farnsworth.org,
 netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, florian@openwrt.org,
 buytenh@wantstofly.org, sebastian.hesselbarth@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20130411.133119.913809939413807690.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 01:31:19PM -0400, David Miller wrote:
> From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Date: Thu, 11 Apr 2013 17:27:03 +0200
> 
> > On Thu, Apr 11, 2013 at 5:03 PM, Willy Tarreau <w@1wt.eu> wrote:
> >> On Thu, Apr 11, 2013 at 04:47:49PM +0200, Sebastian Hesselbarth wrote:
> >>> I tried todays net-next on top of 3.9-rc6 without any gro patch, with
> >>> the initial
> >>> patch (Soeren) and your proposed patch (Willy). The results show that
> >>> both patches
> >>> allow a significant increase in throughput compared to
> >>> netif_receive_skb (!gro, !lro)
> >>> alone. Having gro with lro disabled gives some 2% more throughput
> >>> compared to lro only.
> >>
> >> Indeed this is consistent with my memories, since Eric improved the
> >> GRO path, it became faster than LRO on this chip.
> > 
> > I don't have a strong opinion on whether Soeren's or your proposal should
> > be submitted. But I insist on having one of them in, as GRO significantly
> > improves the common use case, is enabled by default, and not as
> > constrained as LRO.
> 
> I think, as per other drivers, LRO should be eliminated completely from
> all drivers, including this one, and GRO used exclusively instead.

Eric provided me with one such experimental patch in the past for this
driver. It worked for me but we never tried to clean it up to propose
it for inclusion.

If anyone is interested, I might still have it in experimental shape.

Willy

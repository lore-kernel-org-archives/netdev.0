From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/2] ARM: kirkwood: proper retain MAC address workaround
 on DT ethernet
Date: Tue, 28 May 2013 07:50:06 +1000
Message-ID: <1369691406.3557.35.camel@pasglop>
References: <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <51A33447.80305@gmail.com> <1369655404.3557.33.camel@pasglop>
 <2255648.0KEmXfjCx5@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, jason@lakedaemon.net, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 grant.likely@linaro.org, linuxppc-dev@lists.ozlabs.org,
 David Miller <davem@davemloft.net>, buytenh@wantstofly.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <2255648.0KEmXfjCx5@wuerfel>
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

On Mon, 2013-05-27 at 14:47 +0200, Arnd Bergmann wrote:
> On Monday 27 May 2013 21:50:04 Benjamin Herrenschmidt wrote:
> > However, that wouldn't help much with the allocation/leak problem,
> > though at least it would be easier to use. It could also *try* to re-use
> > the current allocation if the new content is of smaller or equal size.
> 
> I thought that dtc tried to aggressively save space by folding identical
> strings. If you tried to reuse a property that had its contents shared
> with another one, you would get interesting results I guess.

It used to be only property names, unless that has changed in recent
dtc. But that's a good point, we probably want a flag in struct property
like we have for nodes, indicating whether it comes from the original
fdt data pool or not.

Cheers,
Ben.

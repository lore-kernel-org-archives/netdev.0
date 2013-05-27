From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/2] ARM: kirkwood: proper retain MAC address workaround
 on DT ethernet
Date: Tue, 28 May 2013 07:48:04 +1000
Message-ID: <1369691284.3557.34.camel@pasglop>
References: <1369647565.3557.28.camel@pasglop> <51A33447.80305@gmail.com>
 <1369655404.3557.33.camel@pasglop>
 <20130527.131857.945196320286011406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, jason@lakedaemon.net, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, buytenh@wantstofly.org, grant.likely@linaro.org,
 linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org,
 sebastian.hesselbarth@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20130527.131857.945196320286011406.davem@davemloft.net>
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

On Mon, 2013-05-27 at 13:18 -0700, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Mon, 27 May 2013 21:50:04 +1000
> 
> > It would be handy to be able to just do something like
> > 
> >       of_set_property(node, name, ptr, len);
> > 
> > However, that wouldn't help much with the allocation/leak problem,
> > though at least it would be easier to use. It could also *try* to re-use
> > the current allocation if the new content is of smaller or equal size.
> 
> And this is so much better of an interface because it allows the
> OF implementation to decide how to deal with memory allocation
> and freeing.

Absolutely, I'm not arguing that point.

Cheers,
Ben.

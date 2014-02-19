From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH] net: ethernet: remove unneeded dependency of mvneta and
 update help text
Date: Wed, 19 Feb 2014 10:10:43 +0800
Message-ID: <20140219101043.5d403398@xhacker>
References: <1392719391-8851-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20140218122952.GM7862@titan.lakedaemon.net>
 <20140218134532.7607a616@skate>
 <20140218125206.GN7862@titan.lakedaemon.net>
 <20140218141303.77c77272@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Jason Cooper
 <jason@lakedaemon.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20140218141303.77c77272@skate>
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

Dear Thomas,

On Tue, 18 Feb 2014 05:13:03 -0800
Thomas Petazzoni <thomas.petazzoni@free-electrons.com> wrote:

> Dear Jason Cooper,
> 
> On Tue, 18 Feb 2014 07:52:06 -0500, Jason Cooper wrote:
> 
> > > No, I haven't tested all the build scenarios of course. If you feel
> > > that this is too dangerous, I can resend a patch that replaces 'depends
> > > on ARMADA_370_XP' by 'depends on PLAT_ORION'. Would this be OK for you?
> > 
> > I'm fine either way.  I'm definitely a "What's in the box?" kind of guy.
> > But I do like being prepared.
> 
> And it's all in your honour!
> 
> > The real question is: Do you think this IP block will ever be found on
> > anything other than Marvell Armada boards?  If so, stick with this
> > version and build test the crap out of it.  Otherwise, let's save
> > opening the box for another day.
> 
> At this point, I don't expect to see this IP in any other SOCs than
> Marvell Armada EBU, so I'll resend with a "depends on PLAT_ORION", as I

This IP is used in Marvell Berlin SoCs too ;)

But Berlin SoC doesn't have a mbus concept. Currently, we just hack the
mvneta to configure the mbus window.

Thanks,
Jisheng

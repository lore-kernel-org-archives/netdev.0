From: Willy Tarreau <w@1wt.eu>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 18:39:37 +0200
Message-ID: <20130916163937.GC3188@1wt.eu>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com>
 <20130915205701.5c61a444@skate> <20130916065047.GH27487@1wt.eu>
 <20130916175152.4e013457@skate>
 <CACzLR4twTNjzU8hK3L1cYUXnEH1ydwY6jnYoOG+9vLB3-4uQ4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 netdev@vger.kernel.org, Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 Gregory =?iso-8859-1?Q?Cl=E9ment?= <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org
To: Ethan Tuttle <ethan@ethantuttle.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <CACzLR4twTNjzU8hK3L1cYUXnEH1ydwY6jnYoOG+9vLB3-4uQ4w@mail.gmail.com>
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

On Mon, Sep 16, 2013 at 09:35:16AM -0700, Ethan Tuttle wrote:
> On Mon, Sep 16, 2013 at 8:51 AM, Thomas Petazzoni
> <thomas.petazzoni@free-electrons.com> wrote:
> > Willy, Ethan,
> >
> > On Mon, 16 Sep 2013 08:50:47 +0200, Willy Tarreau wrote:
> >
> >> I'm currently testing on 3.11.1 (which I had here) and am not getting
> >> any issue after 50M packets. My kernel is running in thumb mode and
> >> without SMP.
> >>
> >> Ethan, we'll need your config I guess.
> >
> > Can both of you also report the U-Boot version you're using, and the
> > SoC revision (it's visible in the U-Boot output).
> 
> Mine says:
> 
> U-Boot 2009.08 (Sep 16 2012 - 22:50:06)Marvell version: 1.1.2 NQ
> SoC:   MV6710 A1

I just checked on my old captures and I have the same here, with more
details such as the CPU's revision (Rev 1) :

   http://1wt.eu/articles/mirabox-vs-guruplug/

Willy

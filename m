From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] qed: Remove OOM messages
Date: Sun, 04 Sep 2016 14:22:20 -0700
Message-ID: <1473024140.5018.61.camel@perches.com>
References: <1472838261.6758.74.camel@perches.com>
         <6d6f56d8324237957b19f069357e2aa9e4bcd959.1472836194.git.joe@perches.com>
         <20160904.132854.1438256363591084718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160904.132854.1438256363591084718.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-09-04 at 13:28 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Fri,  2 Sep 2016 10:48:47 -0700
> 
> > These messages are unnecessary as OOM allocation failures already do
> > a dump_stack() giving more or less the same information.
> > 
> > $ size drivers/net/ethernet/qlogic/qed/built-in.o* (defconfig x86-64)
> >    text          data     bss     dec     hex filename
> >  126849         27968   32800  187617   2dce1 drivers/net/ethernet/qlogic/qed/built-in.o.new
> >  131506         27968   32800  192274   2ef12 drivers/net/ethernet/qlogic/qed/built-in.o.old
> > 
> > Miscellanea:
> > 
> > o Change allocs to the generally preferred forms where possible.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Joe can you respin this against net-next?
> 
> It applies against 'net' but this isn't really a critical bug fix and
> it'll also create conflicts against net-next.

No worries, I'll spin it back after the qed -net changes
are pushed back into net-next.

Oh, they are now.  Give me a minute.

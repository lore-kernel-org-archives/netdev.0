From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 06/13] ppc 8260 fcc ethernet driver cannot read LXT971
 PHY id
Date: Tue, 15 Mar 2005 23:26:51 -0800
Message-ID: <20050315232651.3fd10b13.akpm@osdl.org>
References: <200503152222.j2FMMccq016808@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jgarzik@pobox.com, netdev@oss.sgi.com,
        oray@lucent.com
In-Reply-To: <200503152222.j2FMMccq016808@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
>
> From: "Balasaygun, Oray (Oray)" <oray@lucent.com>
> 
>  - fix for Bug 4310
> 
>  - The fcc_enet.c, as distributed in 2.6.10, does not compile.  Evidently
>    the 2.6 kernel no longer supports the schedule_task() and "struct
>    tq_struct" to go with it.  Lines 73 through and including 96 of the
>    diffout file show the changes I made to port schedule_task() into
>    tasklet_schedule().  I should have reported this as a bug too but I
>    forgot about it.
> 
>  - customize fcc_enet.c to work with my custom board.  These changes are
>    conditional on CONFIG_EON8260 being defined.

Jeff, don't apply this please - we're getting a bunch of patches for this
driver coming from another direction (mvista, freescale.com).  Will take
some time to sort through.

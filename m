From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: possible bug in net/tc35815.c in linux-2.6.19
Date: Mon, 26 Feb 2007 20:05:54 +0900 (JST)
Message-ID: <20070226.200554.125898248.nemoto@toshiba-tops.co.jp>
References: <45E031A3.806@googlemail.com>
	<45E0B651.2050601@garzik.org>
	<20070226102659.GA28439@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, michal.k.k.piotrowski@gmail.com,
	pg@cs.stanford.edu, ahennessy@mvista.com, netdev@vger.kernel.org,
	linux-mips@linux-mips.org,
	Sergei Shtylyov <sshtylyov@ru.mvista.com>
To: ralf@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20070226102659.GA28439@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Feb 2007 10:26:59 +0000, Ralf Baechle <ralf@linux-mips.org> wrote:
> > I created my own patch for this (and one other bug), and checked it in.
> > 
> > Really, though, someone in MIPS-land should give this driver some loving 
> > care.  It is filled with bugs and 2.4-era anachronisms.
> 
> Took a look at it.  It's sort of a non-bug because the driver cannot be
> compiled as module, so the module_exit function cannot possibly be
> executed.  The board support code is calling into the driver which makes
> it impossible to build this driver as a module, yet it's possible to
> select building this driver as a module ...  Oh yeah, that root_tc35815_dev
> stuff is also pretty ugly.

Yes, the driver is quite obsoleted.  It was added long ago with
arch/mips/jmr3927 and not maintained long time, as like as the board
itself.

I know both MontaVista and CELF have new driver for the chip.  If
anybody in MontaVista did not complain I can send CELF's one available
at http://tree.celinuxforum.org/pubwiki/moin.cgi/PatchArchive.  (it
needs some changes for recent kernel, for example pt_regs removal, but
it would be easy).

Sergei?

---
Atsushi Nemoto

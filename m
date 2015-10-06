From: Hans-Peter Nilsson <hans-peter.nilsson@axis.com>
Subject: Re: linux-next: Tree for Oct 6
Date: Tue, 6 Oct 2015 16:46:53 +0200
Message-ID: <201510061446.t96EkrVV012371@ignucius.se.axis.com>
References: <20151006123346.GA5040@sudip-pc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: sfr@canb.auug.org.au, starvik@axis.com, jespern@axis.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com,
	jhs@mojatatu.com
To: sudipm.mukherjee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20151006123346.GA5040@sudip-pc> (message from Sudip Mukherjee on
	Tue, 6 Oct 2015 14:33:46 +0200)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> Date: Tue, 6 Oct 2015 14:33:46 +0200

> On Tue, Oct 06, 2015 at 06:25:22PM +1100, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20151002:
> 
> The build for cris allmodconfig is failing with the error:
> 
> net/sched/sch_dsmark.c: In function 'dsmark_dequeue':
> net/sched/sch_dsmark.c:316:1: error: unrecognizable insn:
> (insn 245 244 119 15 (set (reg:QI 11 r11 [179])
>         (and:QI (mem/s/j:QI (reg/f:SI 2 r2 [orig:48 D.44939 ] [48]) [0 D.44939_34->mask+0 S1 A8])
>             (reg:QI 11 r11 [179]))) include/net/dsfield.h:33 -1
>      (nil))
> net/sched/sch_dsmark.c:316:1: internal compiler error: in extract_insn, at recog.c:2109
> Please submit a full bug report,
> with preprocessed source if appropriate.
> See <http://gcc.gnu.org/bugs.html> for instructions.
> make[2]: *** [net/sched/sch_dsmark.o] Error 1
> make[1]: *** [net/sched] Error 2
> make[1]: *** Waiting for unfinished jobs....
> 
> It says compiler error, but with 4.3-rc4 it compiled properly.
> Build log of v4.3-rc4 is at
> https://travis-ci.org/sudipm-mukherjee/parport/jobs/83633972
> 
> Build log of linux-next is at:
> https://travis-ci.org/sudipm-mukherjee/parport/jobs/83839470

Thanks for the heads-up, but any chance of a bug report as per
the instructions in the message?  It'll only speed up matters.

brgds, H-P

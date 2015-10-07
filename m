From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: linux-next: Tree for Oct 6
Date: Wed, 7 Oct 2015 12:40:46 +0530
Message-ID: <20151007071046.GA21158@sudip-pc>
References: <20151006123346.GA5040@sudip-pc>
 <201510061446.t96EkrVV012371@ignucius.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfr@canb.auug.org.au, starvik@axis.com, jespern@axis.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com,
	jhs@mojatatu.com
To: Hans-Peter Nilsson <hans-peter.nilsson@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201510061446.t96EkrVV012371@ignucius.se.axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 06, 2015 at 04:46:53PM +0200, Hans-Peter Nilsson wrote:
> > From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> > Date: Tue, 6 Oct 2015 14:33:46 +0200
> 
> > On Tue, Oct 06, 2015 at 06:25:22PM +1100, Stephen Rothwell wrote:
> > > Hi all,
> > > 
> > > Changes since 20151002:
> > 
> > The build for cris allmodconfig is failing with the error:
> > 
> > net/sched/sch_dsmark.c: In function 'dsmark_dequeue':
> > net/sched/sch_dsmark.c:316:1: error: unrecognizable insn:
> > (insn 245 244 119 15 (set (reg:QI 11 r11 [179])
> >         (and:QI (mem/s/j:QI (reg/f:SI 2 r2 [orig:48 D.44939 ] [48]) [0 D.44939_34->mask+0 S1 A8])
> >             (reg:QI 11 r11 [179]))) include/net/dsfield.h:33 -1
> >      (nil))
> > net/sched/sch_dsmark.c:316:1: internal compiler error: in extract_insn, at recog.c:2109
> > Please submit a full bug report,
> > with preprocessed source if appropriate.
> > See <http://gcc.gnu.org/bugs.html> for instructions.
> > make[2]: *** [net/sched/sch_dsmark.o] Error 1
> > make[1]: *** [net/sched] Error 2
> > make[1]: *** Waiting for unfinished jobs....
> > 
> > It says compiler error, but with 4.3-rc4 it compiled properly.
> > Build log of v4.3-rc4 is at
> > https://travis-ci.org/sudipm-mukherjee/parport/jobs/83633972
> > 
> > Build log of linux-next is at:
> > https://travis-ci.org/sudipm-mukherjee/parport/jobs/83839470
> 
> Thanks for the heads-up, but any chance of a bug report as per
> the instructions in the message?  It'll only speed up matters.
I can try, but since I am using 4.6.3 version I doubt if I will get the
required response (Happened with another arch). And this is the latest
cris cross-compiler available in
https://www.kernel.org/pub/tools/crosstool/files/bin/x86_64/

BTW, I did a bisect and if I revert 47bbbb30b433 ("sch_dsmark: improve memory locality")
it again builds without any error.

regards
sudip

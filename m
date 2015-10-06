From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: linux-next: Tree for Oct 6
Date: Tue, 6 Oct 2015 18:03:46 +0530
Message-ID: <20151006123346.GA5040@sudip-pc>
References: <20151006182522.09d2d3f5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-cris-kernel@axis.com
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Mikael Starvik <starvik@axis.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151006182522.09d2d3f5@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 06, 2015 at 06:25:22PM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20151002:

The build for cris allmodconfig is failing with the error:

net/sched/sch_dsmark.c: In function 'dsmark_dequeue':
net/sched/sch_dsmark.c:316:1: error: unrecognizable insn:
(insn 245 244 119 15 (set (reg:QI 11 r11 [179])
        (and:QI (mem/s/j:QI (reg/f:SI 2 r2 [orig:48 D.44939 ] [48]) [0 D.44939_34->mask+0 S1 A8])
            (reg:QI 11 r11 [179]))) include/net/dsfield.h:33 -1
     (nil))
net/sched/sch_dsmark.c:316:1: internal compiler error: in extract_insn, at recog.c:2109
Please submit a full bug report,
with preprocessed source if appropriate.
See <http://gcc.gnu.org/bugs.html> for instructions.
make[2]: *** [net/sched/sch_dsmark.o] Error 1
make[1]: *** [net/sched] Error 2
make[1]: *** Waiting for unfinished jobs....

It says compiler error, but with 4.3-rc4 it compiled properly.
Build log of v4.3-rc4 is at
https://travis-ci.org/sudipm-mukherjee/parport/jobs/83633972

Build log of linux-next is at:
https://travis-ci.org/sudipm-mukherjee/parport/jobs/83839470

regards
sudip

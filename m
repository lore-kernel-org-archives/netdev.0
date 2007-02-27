From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: possible bug in net/tc35815.c in linux-2.6.19
Date: Tue, 27 Feb 2007 23:55:23 +0900 (JST)
Message-ID: <20070227.235523.25910390.anemo@mba.ocn.ne.jp>
References: <20070226102659.GA28439@linux-mips.org>
	<20070226.200554.125898248.nemoto@toshiba-tops.co.jp>
	<45E33E13.7010007@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, jeff@garzik.org,
	michal.k.k.piotrowski@gmail.com, pg@cs.stanford.edu,
	ahennessy@mvista.com, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: sshtylyov@ru.mvista.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <45E33E13.7010007@ru.mvista.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Feb 2007 23:07:47 +0300, Sergei Shtylyov <sshtylyov@ru.mvista.com> wrote:
>     Yeah, tc35815_1.c in our looks like the one in the CELF archive (what I 
> didn't get is why they decided to keep both drivers around?)

I think tc35815_1.c can just replace old tc35815.c.  New one lacks
tc35815_killall() which is currently called by arch/mips/jmr3927 code,
but there would be no point doing a such thing.  arch/mips/jmr3927
should be fixed.

>     I think everybody would be just thankful. :-)

OK, I'll prepare a patch after some cleanup.

---
Atsushi Nemoto

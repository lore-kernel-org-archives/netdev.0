From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] (4/4) convert irlan to seq_file interface
Date: Tue, 19 Aug 2003 00:26:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819002637.B7779@electric-eye.fr.zoreil.com>
References: <20030818122702.67e9162d.shemminger@osdl.org> <20030818232554.A7779@electric-eye.fr.zoreil.com> <20030818150514.310f6f5d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030818150514.310f6f5d.shemminger@osdl.org>; from shemminger@osdl.org on Mon, Aug 18, 2003 at 03:05:14PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> If you are going to do that (and it looks good).  Make the str a const
> and use C99 initializers?

I'll add a #define MASK2STR(m,s) { .mask = m, .str = s } and push it as an
incremental patch once the bk-commit mail is here (tomorrow evening then).

--
Ueimor

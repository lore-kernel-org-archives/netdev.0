From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] pktgen handle netdev device getting full.
Date: Thu, 16 Sep 2004 16:20:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916162030.3a65e7d5.davem@davemloft.net>
References: <20040916144332.37f19fcb@dell_ss3.pdx.osdl.net>
	<414A1AD2.1090109@candelatech.com>
	<20040916155913.577b878b.davem@davemloft.net>
	<20040916162051.1b55ae5b@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, Robert.Olsson@data.slu.se, davem@redhat.com,
        netdev@oss.sgi.com, hadi@znyx.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040916162051.1b55ae5b@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 16:20:51 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Well the E1000 fill's it Tx ring and returns TX_BUSY, and on
> SMP can also get TX_LOCKED now.  If that happens, the message shows up.
> Several other drivers don't set stopped when ring is almost full, but
> rely on scheduler to do it for them.

TX_LOCKED is special, and actually this points out that pktgen.c
needs to change how it interprets hard_start_xmit() return
values now that TX_LOCKED is possible too.

I'm sorry, is that what your patch was doing?  Then it was
correct, please resend.

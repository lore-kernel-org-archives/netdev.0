From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net_random_init needs to get seed later in boot process
Date: Mon, 30 Aug 2004 16:54:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830165413.1f31d7e8.davem@davemloft.net>
References: <64243634.20040830173251@huno.net>
	<20040830132030.32d071d0@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tom@huno.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040830132030.32d071d0@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 30 Aug 2004 13:20:30 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Argh.. random_init isn't called until the device's are initialized.
> Rather than mess with random.c initialization, how about this; it resets
> the net_random state late in initialization when get_random_bytes is ready.

I hate this too.  This is the same reason we have to play
games in picking the initial hash random seed in the ipv4
routing cache, for example.

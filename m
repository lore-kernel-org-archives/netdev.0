From: "David S. Miller" <davem@redhat.com>
Subject: Re: [OOPS] TLAN fails on ifconfig with CONFIG_HOTPLUG=n
Date: Tue, 11 Nov 2003 15:55:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111155518.52db3e71.davem@redhat.com>
References: <20031111222933.GA2868@rivenstone.net>
	<20031111153013.3b9eba6e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhf@rivenstone.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031111153013.3b9eba6e.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 11 Nov 2003 15:30:13 -0800
Andrew Morton <akpm@osdl.org> wrote:

> Does this fix it?
 ...
> -} board_info[] __devinitdata = {
> +} board_info[] = {

This fix is needed, definitely.  Even if it doesn't cure this
specific bug.

I'll merge this into my networking tree and push to Linus.

Thanks Andrew.

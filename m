From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] eliminate divert_blk message
Date: Mon, 5 Apr 2004 18:19:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405181925.70897aac.ak@suse.de>
References: <20040405150312.GS11477@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040405150312.GS11477@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 5 Apr 2004 17:03:12 +0200
Olaf Kirch <okir@suse.de> wrote:

> Every time a non-ethernet device is configured (e.g.  when using PPP) the
> kernel logs a message saying "not allocating divert_blk for non-ethernet
> device". This patch disables the message.

Are you sure? All our kernels have CONFIG_NET_DIVERT disabled.  I don't see
how you could get this message unless you enabled it on your own.
If you did that just disable it, it's imho an useless option.

-Andi

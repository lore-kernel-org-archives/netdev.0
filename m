From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix CONFIG_COMPAT with !CONFIG_NET
Date: Wed, 1 Sep 2004 22:26:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901222624.31205ef5.davem@redhat.com>
References: <m3d617k4ex.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m3d617k4ex.fsf@averell.firstfloor.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 31 Aug 2004 12:06:30 +0200
Andi Kleen <ak@muc.de> wrote:

> Fix compilation with CONFIG_COMPAT set and CONFIG_NET disabled.

I like this patch, but...

> -static int ret_einval(unsigned int fd, unsigned int cmd, unsigned long arg)
> +static __attribute__((used)) int 
> +ret_einval(unsigned int fd, unsigned int cmd, unsigned long arg)

Ahem... use something in linux/compiler.h ok? :)

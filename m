From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig schedule fix
Date: Tue, 23 Nov 2004 15:18:55 -0800
Message-ID: <20041123151855.1864659a.davem@davemloft.net>
References: <aec7e5c3041123145030b75d14@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Magnus Damm <magnus.damm@gmail.com>
In-Reply-To: <aec7e5c3041123145030b75d14@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Nov 2004 23:50:35 +0100
Magnus Damm <magnus.damm@gmail.com> wrote:

> This simple patch makes the DHCP/BOOTP/RARP code sleep with
> schedule_timeout() instead of hogging the cpu with cpu_relax() in a
> loop. This comes handy when a guest kernel is booted inside QEMU.
> Without the patch, the host operating system will consume cpu time
> busy waiting.

There are two similar loops involving CONF_PRE_OPEN and CONF_POST_OPEN,
you may wish to hit those while you're at it.

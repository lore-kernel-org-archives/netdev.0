From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: link attribute modification by interface
 name
Date: Tue, 30 Nov 2004 22:28:13 -0800
Message-ID: <20041130222813.0cc61616.davem@davemloft.net>
References: <20041130220659.GK31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041130220659.GK31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Nov 2004 23:06:59 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> This patch allows modification of link attributes by the interface name,
> avoids the requirement of translating a name to an ifindex first, and
> provides better atomicity to userspace.  It works by setting the ifindex
> to a negative number and provide the interface name via the IFLA_IFNAME
> TLV and let the kernel lookup the device by name instead of ifindex. Changing
> the interface name will not work using this method because IFLA_IFNAME also
> transports the new interface name.  The patch also fixes a possible source for
> bugs if IFNAMSIZ is ever changed to a number not aligned to RTA_ALIGNTO.

Looks good, applied to my 2.6.11 pending tree.

Thanks.

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: NETLINK_ROUTE sockets in kernel
Date: Tue, 2 Nov 2004 13:22:22 -0800
Message-ID: <20041102132222.671cf16c.davem@davemloft.net>
References: <2f61ba570411021146657f63f4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anil Gunturu <anil.gunturu@gmail.com>
In-Reply-To: <2f61ba570411021146657f63f4@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Nov 2004 11:46:46 -0800
Anil Gunturu <anil.gunturu@gmail.com> wrote:

> But its not clear on how the rtnetlink_links array is
> populated for PF_NETLINK family. rtnetlink_init seem to populate for
> PF_PACKET and PF_UNSPEC.

This is done via net/ipv4/devinet.c:devinet_init() which sets
rtnetlink_links[] for PF_INET.  Please run grep on the kernel
tree for references to rtnetlink_links[] to see how other
protocol family array entries are initialized.

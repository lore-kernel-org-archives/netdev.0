From: "David S. Miller" <davem@davemloft.net>
Subject: Re: iproute2 patch introducing mtu/txqlen/weight via rtnetlink
Date: Thu, 9 Sep 2004 10:33:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909103344.5a448b01.davem@davemloft.net>
References: <20040909164834.GB18994@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@osdl.org, eric.lemoine@gmail.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040909164834.GB18994@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 18:48:34 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> - Convert mtu and txqlen to use rtnetlink instead of ioctl.
> - Introduces weight.
> - Updates local copy of rtnetlink.h.
> 
> Against iproute2-2.6.9-jamal, tested and working.
> Will look into remaining ioctls later.

Please don't blindly update rtnetlink.h in iproute2 with
the current kernel copy.  The "__KERNEL__" ifdef area
is omitted on purpose, yet you added it back in.

From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: ip route del bug?
Date: Thu, 5 May 2005 11:35:57 -0700
Message-ID: <20050505113557.7d21baf2@dxpl.pdx.osdl.net>
References: <427A3370.3090001@skywaywest.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@znyx.com>, netdev@oss.sgi.com
In-Reply-To: <427A3370.3090001@skywaywest.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 05 May 2005 07:53:36 -0700
Greg Varga <gvarga@skywaywest.com> wrote:

> Hey there,
> 
> I was working on one of our Linux routers yesterday, and when I issued a 
> "ip route del" command (no arg's) by mistake, it deleted the default route.
> 
> I was just wondering if this is indeed the way it was intended, or if 
> its a bug and in fact should have displayed an error message? I 
> personally would have preferred that it error'd with some sort of message.
> 
> I'm running Fedora Core 2 with iproute-2.4.7-14 rpm installed.
> 
> Thanks,
>    --Greg

It looks like an accidental behaviour (of the kernel) in response to
an ip route delete netlink message with no additional data.

Comments?

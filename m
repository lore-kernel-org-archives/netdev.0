From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix erratic behavior in rt6_dump_route()
Date: Mon, 17 Nov 2003 12:43:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117124307.660df624.davem@redhat.com>
References: <Pine.LNX.4.58.0311171155050.21177@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0311171155050.21177@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Nov 2003 12:11:52 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> Hi Dave!
> 
> I noticed some erratic behavior when doing "ip -6 r". I traced the problem
> to rt6_dump_route() where we typecast NLMSG_DATA() to a rtmsg without
> checking the size of the netlink message first. Seems like ip only passes
> a rtgenmsg to the kernel when it does a dump, so we end up reading pure
> garbage when we interpret it as a rtmsg. Please apply the patch!

Thanks a lot Ville, I will review your patch a bit more and
most likely apply it later today.

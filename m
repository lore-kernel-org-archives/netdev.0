From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Handle shared SKBs in VLAN receive code
Date: Sat, 11 Oct 2003 12:03:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011120339.0da631e6.davem@redhat.com>
References: <3F87430D.2040000@tpack.net>
	<3F87464B.1020908@candelatech.com>
	<3F874A30.6010700@tpack.net>
	<3F885418.3090407@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tommy.christensen@tpack.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F885418.3090407@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Oct 2003 12:03:52 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Maybe we should have a method called:  skb_get_me_an_skb_that_I_can_modify(skb);
> 
> Then the subtle differences between sharing, cloning, etc can be handled
> by the skb code internally...

We can't create this routine, because it depends upon context.

The current code is correct and handles shared SKBs properly,
so I don't think it's worth playing around with this much more.

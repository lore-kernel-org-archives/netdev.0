From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 7/7] netpoll: avoid kfree_skb on packets with destructo
Date: Thu, 3 Mar 2005 13:41:19 -0800
Message-ID: <20050303134119.64a24678.davem@davemloft.net>
References: <7.454130102@selenic.com>
	<8.454130102@selenic.com>
	<20050303130031.066f0862.davem@davemloft.net>
	<42277ED6.4020707@pobox.com>
	<20050303132906.2b5d597f.davem@davemloft.net>
	<20050303213911.GV3120@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, jmoyer@redhat.com
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050303213911.GV3120@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Mar 2005 13:39:11 -0800
Matt Mackall <mpm@selenic.com> wrote:

> The lock only happens if CONFIG_NETPOLL=y _and_ a netpoll client (eg
> netconsole) is registered on the device in question.

I actually missed that condition.  This is less intrusive then.
I'm actually ok with these changes therefore.

I'll merge these patches in (with the SKB leak fix of course)
and will push upstream once we work out how 2.6.x development
is going to process :-)

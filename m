From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: Incorrect hoplimit in ip6_push_pending_frames()
Date: Sat, 2 Aug 2003 22:59:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030802225948.01c96fb7.davem@redhat.com>
References: <Pine.LNX.4.44.0307041601570.15229-100000@rhea.tcs.hut.fi>
	<Pine.LNX.4.44.0308011353520.16201-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308011353520.16201-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Aug 2003 14:15:21 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> I noticed the hop limit passed to ip6_append_data() isn't used by
> ip6_push_pending_frames(), which might lead to unexpected behavior with
> multicast and (ipv6-in-ipv6) tunneled packets. This patch (against Linux
> 2.6.0-test2 and cset 1.1595) fixes the problem.

Applied, thank you.

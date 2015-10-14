From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ICMPv6 too big Packet will makes the network unreachable
Date: Wed, 14 Oct 2015 10:44:47 +0200
Message-ID: <1444812287.2143451.409784161.5A6B4523@webmail.messagingengine.com>
References: <CAJFZqHz93RmSp369W508i8zbDmxhohG9n4UfxG1TnSxDPD4B=g@mail.gmail.com>
 <1444746394.1871555.408986697.6F3FA822@webmail.messagingengine.com>
 <CAJFZqHzECmw=RYa7p3kcc=VAbTYf1ZrBPj+X=atnxn2HsChdCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41295 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751742AbbJNIos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 04:44:48 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id D7F80204CB
	for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 04:44:47 -0400 (EDT)
In-Reply-To: <CAJFZqHzECmw=RYa7p3kcc=VAbTYf1ZrBPj+X=atnxn2HsChdCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Oct 14, 2015, at 08:44, Li RongQing wrote:
> On Tue, Oct 13, 2015 at 10:26 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> >>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
> >>    2001:1b70:82a8:18:650:65:0:2 dev eth10.650  src
> >> 2001:1b70:82a8:18:650:65:0:2  metric 0
> >>        cache
> >>    root@du1:~#
> >
> > Which kernel version did you test this on?
> >
> > Thanks,
> > Hannes
> 
> 
> I think it is all version

I wonder very much because in tests I definitely hit the

static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct
sock *sk,
				 const struct ipv6hdr *iph, u32 mtu)
{
	struct rt6_info *rt6 = (struct rt6_info *)dst;

	if (rt6->rt6i_flags & RTF_LOCAL)
		return;

RTF_LOCAL check all the times. Which kernel version did you on
specifically?

Thanks,
Hannes

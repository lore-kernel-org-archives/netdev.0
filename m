From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: critic on documentation of the network stack
Date: Sat, 25 Jan 2014 00:44:29 +0100
Message-ID: <CAFLxGvy8KDcZx1sR_cYW8WznWEe+dGxQZsxq-BaKgpcGjw4Hiw@mail.gmail.com>
References: <20140124032324.GO7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:36416 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbaAXXo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 18:44:29 -0500
Received: by mail-oa0-f52.google.com with SMTP id i4so4518743oah.39
        for <netdev@vger.kernel.org>; Fri, 24 Jan 2014 15:44:29 -0800 (PST)
In-Reply-To: <20140124032324.GO7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 24, 2014 at 4:23 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hello!
>
> After net-next is closed I wanted to put the following link here:
>
>   <http://linux.slashdot.org/comments.pl?sid=4356053&cid=45184693>
>
> I don't want to start a flamefest or come too close to someone but I
> fear some of the critic is reasonable.  Maybe we can do better (I have
> to admit, I also hate writing documentation, e.g. have not yet send the
> IP_PMTUDISC_INTERFACE man-page patches).
>
> I try to start with some constructive discussion:
>
> There are some great features in the network stack that some people miss
> because of lack documentation. One possible solution is documentation
> directly in the kernel, but mostly this is just written as a reference
> and the real wonderful stuff is only achieved by putting lots of those
> features correclty together.
>
> Maybe this is the second or third time this was proposed but I'll try
> again: Would it make sense to just start slow and setup a wiki where we
> just throw in the various snippets we use for testing while developing
> patches, maybe with a bit of background information? This may well attract
> interested people outside of netdev@ which could start helping cleaning
> up the wiki or add more useful documentation on their own. We could
> check from time to time what could be fed back into Documentation/? The
> reason why I would definitely help to improve the wiki is because I
> am sure I can learn from other setups and testing methodologies, too,
> and definitely still have not yet seen everything what is possible with
> the linux network stack.

I fully agree with you. Kernel features without userspace docs suck.
I'm not sure whether a wiki is a good idea but at least the manpages
be kept in sync.

The tcp socket option TCP_CONGESTION is such a case.

Kernel implemenation was added by:
commit 5f8ef48d240963093451bcf83df89f1a1364f51d
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Thu Jun 23 20:37:36 2005 -0700

    [TCP]: Allow choosing TCP congestion control via sockopt.

    Allow using setsockopt to set TCP congestion control to use on a per
    socket basis.

    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Linux manpages tell about the feature since:
commit d6d58656220f3ee24990e88dd9f37967a46fb290
Author: Michael Kerrisk <mtk.manpages@gmail.com>
Date:   Fri Nov 21 12:29:37 2008 -0500

    tcp.7: Document /proc file tcp_allowed_congestion_control (new in
Linux 2.4.20)

    Text taken from Documentation/networking/ip-sysctl.txt

    Signed-off-by: Michael Kerrisk <mtk.manpages@gmail.com>

and finally:
commit bf561a0fbcfed101aea2d523fe5cd50e90273786
Author: Michael Kerrisk <mtk.manpages@gmail.com>
Date:   Thu Jan 23 05:11:10 2014 +0100

    tcp.7: Document TCP_CONGESTION

    Signed-off-by: Michael Kerrisk <mtk.manpages@gmail.com>


A hardcore net/ hacker may know all nice features but joey random
network programer
just reads the manpages...

-- 
Thanks,
//richard

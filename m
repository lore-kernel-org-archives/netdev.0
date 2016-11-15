From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v3 3/7] vxlan: simplify exception handling
Date: Tue, 15 Nov 2016 18:04:53 +0100
Message-ID: <20161115180453.26105ba8@griffin>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
        <1479098638-4921-4-git-send-email-pshelar@ovn.org>
        <20161115153014.38fa2480@griffin>
        <CAOrHB_CQEeknxznNu5u=PhD8pGdPxg+HBinTu7+rz77tj2+wNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751359AbcKORE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 12:04:57 -0500
In-Reply-To: <CAOrHB_CQEeknxznNu5u=PhD8pGdPxg+HBinTu7+rz77tj2+wNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Nov 2016 08:40:58 -0800, Pravin Shelar wrote:
> On Tue, Nov 15, 2016 at 6:30 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > It would be a bit cleaner to do this assignment just after rt is
> > assigned (but after the IS_ERR(rt) condition), get rid of the added
> > ip_rt_put call above and move the existing ip_rt_put call in the bypass
> > case just before the vxlan_encap_bypass call...
> >
> Does it really matters given that next patches in this series moves
> this duplicate code and does pretty much what you are describing?

Okay, right. I tried to look also at patches further in the series but
it seemed to me this will leave an instance of ip_rt_put that could be
avoided. But it will not.

Acked-by: Jiri Benc <jbenc@redhat.com>

(It would make the reviewers' life easier if the individual patches
were more self contained. Ideally, each patch should be able to stand
on its own. This unrelated code shuffling makes it too easy to miss
things...)

Anyway, thanks for the cleanup!

 Jiri

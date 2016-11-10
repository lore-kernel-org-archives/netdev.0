From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 6/7] vxlan: simplify vxlan xmit
Date: Thu, 10 Nov 2016 11:08:37 +0100
Message-ID: <20161110110837.2f9c97c4@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-7-git-send-email-pshelar@ovn.org>
        <20161109175902.01e096ad@griffin>
        <CAOrHB_DneqHEg7Hi3SH0GebeN7TUoeKDevbwTatuhGgXrZOTbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39334 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752771AbcKJKIl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 05:08:41 -0500
In-Reply-To: <CAOrHB_DneqHEg7Hi3SH0GebeN7TUoeKDevbwTatuhGgXrZOTbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Nov 2016 19:35:00 -0800, Pravin Shelar wrote:
> On Wed, Nov 9, 2016 at 8:59 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > Uninitialized old_iph.
> >
> It is initialized in begining of this function.

Right you are, sorry.

> TOS and TTL is initialized for LWT just else block. so I do not see
> any changes compared to current implementation.

Oh, right. We set them unconditionally from tunnel_info. I was
convinced we fallback to the interface config values when they're not
given and stopped reviewing the patch but we don't.

This is a nice cleanup, thanks!

Acked-by: Jiri Benc <jbenc@redhat.com>

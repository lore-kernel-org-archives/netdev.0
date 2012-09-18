From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V4 0/2] Add rtnl_link_ops support to IPoIB
Date: Tue, 18 Sep 2012 23:07:54 +0300
Message-ID: <CAJZOPZL6cEEbyMgj+3_h-ZHf0jzNs3yF=f3uOTrKB6EO4Vx2yw@mail.gmail.com>
References: <1347551797-2495-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Roland Dreier <roland@kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55975 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583Ab2IRUHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 16:07:55 -0400
Received: by iahk25 with SMTP id k25so219394iah.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 13:07:54 -0700 (PDT)
In-Reply-To: <1347551797-2495-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 13, 2012 at 6:56 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> This is about adding rtnl_link_ops to IPoIB, primarly addressing feedback
> from Dave on a similar patch that was part of the eIPoIB submission.
[...]
> Roland, this patch is hanging out for pretty long while (few months) without
> any comment from you, if it makes things easier, I would like to merge it through
> net-next, makes sense?


Hi Roland,

Haven't heard from you on this patch, are you picking this or it can
get in though net-next?

Or.

> Changes from V3:
>  - addressed feedback from Patrick McHardy to move the IFLA_IPOIB_yyy ipoib
>    rtnl defintions into include/linux/if_link.h
>  - changed IFLA_IPOIB_CHILD_PKEY to be named IFLA_IPOIB_PKEY which will cope
>    with more IFLA_IPOIB_yyy entries to be added once the basic support is in
>
> Changes from V2:
>  - removed the notion of user defined index per child, since we can do well w.o it
>  - for that end, make (an internal to ipoib) distrinction between legacy childs created
>    through the old sysfs way to childs created using rtnl link ops
>
> Changes from V1:
>  - applied feedback from Dave Miller to avoid using sysfs
>  - added rtnl_link_ops support in ipoib and use them to add/delete childs
>
> Or Gerlitz (1):
>   IB/ipoib: Add rtnl_link_ops support

From: David Miller <davem@davemloft.net>
Subject: Re: slab corruption with current -git
Date: Sun, 09 Oct 2016 23:57:45 -0400 (EDT)
Message-ID: <20161009.235745.860945462339053703.davem@davemloft.net>
References: <f7tbmytkmtr.fsf@redhat.com>
        <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
        <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aconole@redhat.com, fw@strlen.de, viro@zeniv.linux.org.uk,
        akpm@linux-foundation.org, axboe@fb.com, tytso@mit.edu,
        cl@linux.com, pablo@netfilter.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbcJJD5y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 23:57:54 -0400
In-Reply-To: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 9 Oct 2016 20:41:17 -0700

> Note that the "correct way" of doing list operations also almost
> inevitably is the shortest way by far, since it gets rid of all the
> special cases. So the patch looks nice. It gets rid of the magic
> "nf_set_hooks_head()" thing too, because once you do list following
> right, the head is no different from any other pointer in the list.

Perhaps we should have some "slist" primitives added to
include/linux/list.h but since the comparison differs for each user I
guess it's hard to abstract in a way that's generic and inlines
properly.

I'll start taking a look at your patch and this stuff as well, thanks
Linus.

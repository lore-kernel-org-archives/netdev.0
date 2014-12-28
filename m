From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: net.git: Call-trace after "Merge branch 'netlink_multicast'"
Date: Sun, 28 Dec 2014 07:22:15 +0100
Message-ID: <CA+icZUWFq0FT5QQThKeeVw4=-41R7W0Q7zv53ZCY9=B6AJvf7w@mail.gmail.com>
References: <CA+icZUVkNHBqCn66onJP9i5vfVzHR9mdSFXyiBFyjhkrySrSzQ@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:54126 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbaL1GWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 01:22:16 -0500
Received: by mail-wg0-f43.google.com with SMTP id l18so16775122wgh.30
        for <netdev@vger.kernel.org>; Sat, 27 Dec 2014 22:22:15 -0800 (PST)
In-Reply-To: <CA+icZUVkNHBqCn66onJP9i5vfVzHR9mdSFXyiBFyjhkrySrSzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 28, 2014 at 6:39 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
[ ... ]
> [ CCing Fengguang Wu who reported the same issue on LKML (see [0]) ]
>
> Was "netlink/genetlink: pass network namespace to bind/unbind" patch
> [1] forgotten in this 'netlink_multicast' merge?

OK, this patch is additional and on top of "[PATCH 0/5]
netlink/genetlink cleanups & multicast improvements"

- Sedat -

[1] http://marc.info/?l=linux-netdev&w=2&r=1&s=netlink&q=b

> I also tested with that patch on top of net.git#master.
> The warning still remains.
>
> I have #if 0-ed the WARN_ON() for now (see attached patch), this makes
> the warning go away for me.
>
> BTW, I looked through the patches listed in [2] but this list seems to
> be truncated.
> Then I looked again at the linux-netdev ML where I found Johannes'
> patch and Dave replied "Applied, thanks Johannes." (see thread in
> [3]).
> Forgot to push out?
>
> - Sedat -
>
> [0] http://marc.info/?l=linux-kernel&m=141972716410805&w=2
> [1] http://patchwork.ozlabs.org/patch/423799/
> [2] http://patchwork.ozlabs.org/project/netdev/list/
> [3] http://marc.info/?t=141936487400002&r=1&w=2

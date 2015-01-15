From: "Alexander Y. Fomichev" <git.user@gmail.com>
Subject: Re: net: prevent of emerging cross-namespace symlinks patches for 3.14?
Date: Thu, 15 Jan 2015 22:39:53 +0400
Message-ID: <CAChDUfTktt7DAg+Mi0+PWcykhHWvE9wg5FNieWUuoBjZGsU8jQ@mail.gmail.com>
References: <54B6E36F.9060703@xs4all.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, stable@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <54B6E36F.9060703@xs4all.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

no objections of course,
actually it was written and tested with 3.14 in mind.

On Thu, Jan 15, 2015 at 12:45 AM, Miquel van Smoorenburg
<mikevs@xs4all.net> wrote:
> [first sent to lkml, now to netdev and the original patch author]
>
> When running 'lxc' on the latest -stable kernel, 3.14.28, I'm seeing these
> errors:
>
> Jan 14 17:47:16 lxc2 kernel: [   10.704890] WARNING: CPU: 0 PID: 3209 at
> fs/sys
> fs/dir.c:52 sysfs_warn_dup+0x8c/0xb0()
> Jan 14 17:47:16 lxc2 kernel: [   10.704892] sysfs: cannot create duplicate
> filename '/devices/virtual/net/eth0.104/upper_eth0'
> Jan 14 17:47:16 lxc2 kernel: [   10.704954] CPU: 0 PID: 3209 Comm:
> lxc-autostart Not tainted 3.14.28-xsserver #1
>
> I did not see these errors in 3.12. This was fixed in 3.17 by:
>
> net: prevent of emerging cross-namespace symlinks
> https://github.com/torvalds/linux/commit/4c75431ac3520631f1d9e74aa88407e6374dbbc4
>
> net: fix creation adjacent device symlinks
> https://github.com/torvalds/linux/commit/7ce64c79c4decdeb1afe0bf2f6ef834b382871d1
>
> These patches apply cleanly to 3.14.28.
>
> If you agree that this should go into 3.14-stable, please ack.
>
> Thanks,
>
> Mike.



-- 
Best regards.
       Alexander Y. Fomichev <git.user@gmail.com>

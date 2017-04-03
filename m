From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: skb_over_panic using UDP and 6lowpan / fakelb
Date: Mon, 3 Apr 2017 10:29:55 -0700
Message-ID: <CAM_iQpWqQj3FLpBLE1Z+==Z7tJGXHyHXTvLmKRCNjyc=vtQvnQ@mail.gmail.com>
References: <56012235-e1d0-1e5e-840a-cc8d5938c380@ntnu.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        aar@pengutronix.de, stefan@osg.samsung.com,
        linux-wpan@vger.kernel.org
To: David Palma <david.palma@ntnu.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56012235-e1d0-1e5e-840a-cc8d5938c380@ntnu.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev and maintainers)

On Mon, Mar 27, 2017 at 2:16 AM, David Palma <david.palma@ntnu.no> wrote:
>
> Hi,
>
> Sending a simple UDP packet (39 bytes long), over a 6lowpan interface
> (using fakelb), creates a kernel panic (skb_over_panic).
>
> Steps to reproduce, and more details, can be found in:
> https://github.com/PalmaITEM/6lowpan-skb_over_panic
>
> This bug has been reported in
> https://bugzilla.kernel.org/show_bug.cgi?id=195059
>
> I have found that lengths around 39 bytes can also trigger this
> behaviour and that longer packets are handled without problem.
>
> Verified in:
>
> - Linux version 4.9.0-0.bpo.2-amd64 (debian-kernel@lists.debian.org)
> (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Debian 4.9.13-1~bpo8+1
> (2017-02-27)
> - Linux version 4.10.4-1-ARCH (builduser@tobias) (gcc version 6.3.1
> 20170306 (GCC) ) #1 SMP PREEMPT Sat Mar 18 19:39:18 CET 2017
>
>
> I am not familiar with the process of reporting kernel bugs, so
> apologies beforehand. I am also available to provide any missing
> information.
>
> Cheers,
> --
> David Palma
>

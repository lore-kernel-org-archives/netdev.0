From: John Stultz <john.stultz@linaro.org>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Wed, 9 Aug 2017 17:44:30 -0700
Message-ID: <CALAqxLW6Gr67iP80F5OA8bhj8u2LTdbf31krF16Siek7C4DkHg@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
 <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com>
 <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com> <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
To: Wei Wang <weiwan@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 9, 2017 at 5:36 PM, Wei Wang <weiwan@google.com> wrote:
>
> Does your USB adapter get an IPv6 address?

Yes, it does.

> If you see the problem starts to happen on commit
> 9514528d92d4cbe086499322370155ed69f5d06c, could you try reverting all
> the following commits:
> (from new to old)
> 1eb04e7c9e63 net: reorder all the dst flags
> a4c2fd7f7891 net: remove DST_NOCACHE flag
> b2a9c0ed75a3 net: remove DST_NOGC flag
> 5b7c9a8ff828 net: remove dst gc related code
> db916649b5dd ipv6: get rid of icmp6 dst garbage collector
> 587fea741134 ipv6: mark DST_NOGC and remove the operation of dst_free()
> ad65a2f05695 ipv6: call dst_hold_safe() properly
> 9514528d92d4 ipv6: call dst_dev_put() properly
>
> and try if it starts to work?

I'll give that a shot!

Thanks so much for the help! I really appreciate it!
-john

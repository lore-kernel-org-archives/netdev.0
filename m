From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Mon, 23 Jan 2017 11:00:17 -0800
Message-ID: <CAM_iQpWDO671sT-GQpu7c1UeyaLMX+rt7bUhqtF8tnxMqyeK4Q@mail.gmail.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk> <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk> <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
 <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
 <CACT4Y+Y_3i=PThhVzHXYnCQm_xN72VQ0eN9Ae4uXyORq_a_Z6w@mail.gmail.com>
 <CAM_iQpUtirzcm901Gh6918g2yROo3FFKb6Vx87Wtj7M31wE6DA@mail.gmail.com> <CACT4Y+Yf5S1OiNdd8WH=bmge=25m3zOh48QB8iq2nsKESG6Z_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Yf5S1OiNdd8WH=bmge=25m3zOh48QB8iq2nsKESG6Z_Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2017 at 2:52 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>
> This works! I did not see the deadlock warning, nor any other related crashes.
>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>

Thanks for verifying it. I will send it out formally soon.

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: sysctl, argument parsing, possible bug
Date: Tue, 1 Aug 2017 14:54:51 -0700
Message-ID: <CAM_iQpV8rJOxvA+hT4Dfs_+sJv5N9ZVv5DCgYDxjpvr2X124ww@mail.gmail.com>
References: <CAKv20-VuR4J0PJOOfsRmEPMhB+vKYMdPsp5wDgVkoYwrHxgLGw@mail.gmail.com>
 <CAM_iQpXtHACnD8kmmHd4bcg+Khy5Y0K=HMmc08avTSHov4zN1A@mail.gmail.com> <CAKv20-VFcdZti=4a6QzVJH0wAYGpqo2umktRPr19tv+btSZY_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Kees Cook <keescook@chromium.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Massimo Sala <massimo.sala.71@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKv20-VFcdZti=4a6QzVJH0wAYGpqo2umktRPr19tv+btSZY_w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 1, 2017 at 2:34 PM, Massimo Sala <massimo.sala.71@gmail.com> wrote:
> Do you confirm it is a sysctl parsing bug ?
>
> Bosybox handles these cases, so I think also standalone sysctl have to.
>
> Or at least someone must update sysctl docs / MAN about this.
>

Maybe, sysctl seems (I never look into it) just to interpret dot as
a separator, unless it reads from the /proc/sys/ directory, it can
not know eth0.100 is actually a netdev name.

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net_sched: fix order of queue length updates in qdisc_replace()
Date: Sat, 19 Aug 2017 10:58:37 -0700
Message-ID: <CAM_iQpX9C3r8OTeB3AjqwcDGbV=Yc_vid4YOzQML9cQ38UAhtw@mail.gmail.com>
References: <150314622756.18396.5215271249872220640.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@resnulli.us>, stable@vger.kernel.org
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <150314622756.18396.5215271249872220640.stgit@buzz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 19, 2017 at 5:37 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> This important to call qdisc_tree_reduce_backlog() after changing queue
> length. Parent qdisc should deactivate class in ->qlen_notify() called from
> qdisc_tree_reduce_backlog() but this happens only if qdisc->q.qlen in zero.

Good catch! I didn't realize qdisc_reset() actually resets all classes...

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

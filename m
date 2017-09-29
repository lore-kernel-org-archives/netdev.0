From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH][net-next] net_sched: remove redundant assignment to ret
Date: Fri, 29 Sep 2017 10:35:20 -0700
Message-ID: <CAM_iQpUEKK4jJo9aPLExudGXub4j_Mz8Jv+Lu+wJTGj3Zk7Jmw@mail.gmail.com>
References: <20170929140116.8642-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929140116.8642-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 29, 2017 at 7:01 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> The assignment of -EINVAL to variable ret is redundant as it
> is being overwritten on the following error exit paths or
> to the return value from the following call to basic_set_parms.
> Fix this up by removing it. Cleans up clang warning message:
>
> net/sched/cls_basic.c:185:2: warning: Value stored to 'err' is never read
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Fixes: 1d8134fea2eb ("net_sched: use idr to allocate basic filter handles")

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

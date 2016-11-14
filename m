From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] genetlink: fix unsigned int comparison with less than zero
Date: Sun, 13 Nov 2016 22:29:42 -0800
Message-ID: <CAM_iQpWSVtkzNYZTc_He+8QxorOhNKRTyQd6qXVGb7Tvihj5tQ@mail.gmail.com>
References: <20161110155758.26996-1-colin.king@canonical.com> <20161113.121519.399311594808700910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Colin King <colin.king@canonical.com>,
        Johannes Berg <johannes.berg@intel.com>,
        pravin shelar <pshelar@ovn.org>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Florian Westphal <fw@strlen.de>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161113.121519.399311594808700910.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 13, 2016 at 9:15 AM, David Miller <davem@davemloft.net> wrote:
> I've commited the following to net-next:
>
> ====================
> [PATCH] genetlink: Make family a signed integer.
>
> The idr_alloc(), idr_remove(), et al. routines all expect IDs to be
> signed integers.  Therefore make the genl_family member 'id' signed
> too.

This is exactly what I replied to Johannes.

Thanks for the fix!

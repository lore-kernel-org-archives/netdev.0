From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v7 10/33] net: dummy - set name assign type
Date: Thu, 10 Jul 2014 12:33:57 +0200
Message-ID: <CAG-2HqV0LV_ZtK=S-nLsWAfQ_ayOuGZHcGC495pAkMijeSzx3Q@mail.gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
 <1404980258-30853-11-git-send-email-teg@jklm.no> <87pphdh85q.fsf@nemi.mork.no>
 <CAG-2HqWSRRfW1EygXd_1=eYFsTeDd3SsJBfF3BuH35hgGxogxA@mail.gmail.com> <CANq1E4TCW_bnbTYacnfJHRvZAcOYnSgqxytHk26EaWeQKkphGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Kay Sievers <kay@vrfy.org>,
	dingtianhong <dingtianhong@huawei.com>,
	Tan Xiaojun <tanxiaojun@huawei.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANq1E4TCW_bnbTYacnfJHRvZAcOYnSgqxytHk26EaWeQKkphGA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 10, 2014 at 12:26 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> Hi
>
>>> The same goes for NET_NAME_USER and NET_NAME_RENAMED. These are the same
>>> from a kernel point of view.
>>
>> You mean to collapse the two, and just label renamed interfaces
>> NET_NAME_USER instead?
>
> I have no real objections to merging NAME_USER and NAME_RENAMED. Both
> values imply that there is a user-space authority that applied some
> kind of rules to the naming-scheme. Therefore, anyone reacting to
> those names should better treat them equally and fix the
> naming-authority instead of overwriting it.

I basically agree. There is no strong reason to keep these separate,
so I would not object strongly to merging them.

However, I also don't see any harm in keeping the distinction. If
userspace wants to treat them the same, it easily can. However, if a
usecase appears in the future where the distinction is important, we
can no longer split them apart again. For that reason, I'd slightly
prefer keeping them separate, unless there is a compelling reason not
to...

Cheers,

Tom

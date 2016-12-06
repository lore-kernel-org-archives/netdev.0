From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH]net:sched:release lock before tcf_dump_walker() normal
 return to avoid deadlock
Date: Tue, 6 Dec 2016 08:50:18 -0500
Message-ID: <c2b3ff55-7636-4b38-ca06-54d5ff75f4bf@mojatatu.com>
References: <CAEX1niWim7BSki6uRtihwbJ3Adw4Qwt8MR1aki8UA4_x7V9UTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        feng.deng@cortina-access.com, Roman Mashak <mrv@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Feng Deng <cxdx2006@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEX1niWim7BSki6uRtihwbJ3Adw4Qwt8MR1aki8UA4_x7V9UTA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-12-06 12:36 AM, Feng Deng wrote:
> From: Feng Deng<cxdx2006@gmail.com>
>
> release lock before tcf_dump_walker() normal return to avoid deadlock
>

/Scratching my head.

I am probably missing something obvious.
What are the condition under which this deadlock will happen?
Do you have a testcase we can try?

cheers,
jamal

From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] netfilter: xtables target SYNPROXY
Date: Sat, 4 Sep 2010 07:07:00 +0800
Message-ID: <AANLkTim_rq1ZK=rX0of=U5HfBw3_byYbrapz4HF4T+UA@mail.gmail.com>
References: <1278044350-3136-1-git-send-email-xiaosuo@gmail.com> <AANLkTim_sgZhrcgvuH0=hFTfE-beMezvcvw6PspXRvHx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Fabricio Archanjo <farchanjo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim_sgZhrcgvuH0=hFTfE-beMezvcvw6PspXRvHx@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 4, 2010 at 4:29 AM, Fabricio Archanjo <farchanjo@gmail.com> wrote:
> hey all,
> is this patch gonna be on kernel tree?
> It works fines. Yesterday I was over attack, after applied this patch
> my problem was solved. It hasn't dropped real connections. Sometimes i
> changed to freebsd due synproxy state on pf.
>
>
> Thanks,

Thanks for the test and feedback. No other comments are added after
the RFC. Maybe because it lacks the IPv6 support.

There is another issue: when calculating MSS, we'd better check the
MSS of the forward path too. However, as it works in RAW table, and no
DNAT/REDIRECT is performed, we may get the wrong info.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)

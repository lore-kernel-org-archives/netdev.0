From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Tue, 01 Nov 2016 11:38:33 -0400 (EDT)
Message-ID: <20161101.113833.983996221243204456.davem@davemloft.net>
References: <CAKD1Yr3QfL-biSjQfFgzjMFNoLV7FP9DSB=KNbp+_KyxyQmVMg@mail.gmail.com>
        <581506C4.30902@iogearbox.net>
        <CAKD1Yr02SCHvd-xZJL14d_Ta8Dk4evHZ60zytpU0h4r80FucwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, htejun-b10kYP2dOMg@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: lorenzo-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKD1Yr02SCHvd-xZJL14d_Ta8Dk4evHZ60zytpU0h4r80FucwA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Lorenzo Colitti <lorenzo-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Date: Wed, 2 Nov 2016 00:25:15 +0900

> That way, if you want to modify the packet or do something
> sophisticated in netfilter, you can still use the eBPF hook on the
> results of that operation, and if you don't want to run netfilter, you
> can write netfilter rules to skip the packet (and maybe still fix it
> up later, perhaps in another netfilter chain).

The downside is that we classify the packet twice.  This transactional
cost adds up rather quickly.

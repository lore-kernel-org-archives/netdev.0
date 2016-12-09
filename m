From: Tejun Heo <tj@kernel.org>
Subject: Re: [RESEND][PATCH v4] cgroup: Use CAP_SYS_RESOURCE to allow a
 process to migrate other tasks between cgroups
Date: Fri, 9 Dec 2016 08:27:21 -0500
Message-ID: <20161209132721.GA30394@mtj.duckdns.org>
References: <CALCETrW_mPHneTvcAM6HyBLCJqcwKmcYEoC+kseyuyQZzj2a=A@mail.gmail.com>
 <CALAqxLXk+A9=A0oXGEduphXOQdbMg-wuGxmLkEk9cPHyn44X5Q@mail.gmail.com>
 <CALAqxLW-mq4Lnudtn5KMBPdzBTg5bhTXV9QmUC2vfabVru+fUA@mail.gmail.com>
 <CALCETrWuKpmXQqoQmcy4Va8abdpfCnMBYHWSD0nK5pocj2nfXA@mail.gmail.com>
 <20161206165519.GA17648@mtj.duckdns.org>
 <CALCETrV3Yrq1hRcoGCTU_z-T-6hmq-gY-HytR2HGkvnRK-W1SQ@mail.gmail.com>
 <20161206181221.GA2625@mtj.duckdns.org>
 <CALCETrUmwPaWbN_U2XAsg6Z0UGBJ=Ou7BoD09-GZFdRVT5Y-EQ@mail.gmail.com>
 <20161206182315.GB2625@mtj.duckdns.org>
 <CALAqxLUkqSAEiHE038w+ZGUmhPgj2SpG7BLcPrrtU46VYcO=KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@amacapital.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Daniel Mack <daniel@zonque.org>,
        "David S. Miller" <davem@davemloft.net>, kafai@fb.com,
        Florian Westphal <fw@strlen.de>,
        Harald Hoyer <harald@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        Sargun Dhillon <sargun@sargun.me>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Li Zefan <lizefan@huawei.com>,
        Jonathan Corbet <corbet@lwn.net>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
        Android Kernel Team <kernel-team@android.com>,
        Rom Lemarchand <romlem@android.com>,
        Colin Cross <ccross@android.com>,
        Dmitry Shmidt
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALAqxLUkqSAEiHE038w+ZGUmhPgj2SpG7BLcPrrtU46VYcO=KA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, John.

On Thu, Dec 08, 2016 at 09:39:38PM -0800, John Stultz wrote:
> So just to clarify the discussion for my purposes and make sure I
> understood, per-cgroup CAP rules was not desired, and instead we
> should either utilize an existing cap (are there still objections to
> CAP_SYS_RESOURCE? - this isn't clear to me) or create a new one (ie,
> bring back the older CAP_CGROUP_MIGRATE patch).

Let's create a new one.  It looks to be a bit too different to share
with an existing one.

> Tejun: Do you have a more finished version of your patch that I should
> add my changes on top of?

Oh, just submit the patch on top of the current for-next.  I can queue
mine on top of yours.  They are mostly orthogonal.

Thanks.

-- 
tejun

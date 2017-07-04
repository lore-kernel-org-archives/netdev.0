From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] v2 ipv4/ipv6 refcount conversions
Date: Tue, 04 Jul 2017 01:39:38 -0700 (PDT)
Message-ID: <20170704.013938.680822769277278352.davem@davemloft.net>
References: <1499150102-7478-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org
To: elena.reshetova@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499150102-7478-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elena Reshetova <elena.reshetova@intel.com>
Date: Tue,  4 Jul 2017 09:34:53 +0300

> Changes in v2:
>  * rebase on top of net-next
>  * currently by default refcount_t = atomic_t (*) and uses all 
>    atomic standard operations unless CONFIG_REFCOUNT_FULL is enabled.
>    This is a compromise for the systems that are critical on
>    performance (such as net) and cannot accept even slight delay
>    on the refcounter operations.
> 
> This series, for ipv4/ipv6 network components, replaces atomic_t reference
> counters with the new refcount_t type and API (see include/linux/refcount.h).
> By doing this we prevent intentional or accidental
> underflows or overflows that can led to use-after-free vulnerabilities.
> 
> The patches are fully independent and can be cherry-picked separately.
> In order to try with refcount functionality enabled in run-time,
> CONFIG_REFCOUNT_FULL must be enabled.
 ...

Series applied, thanks.

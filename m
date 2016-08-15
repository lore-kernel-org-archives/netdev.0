From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/5] hv_netvsc: fixes for VF removal path
Date: Mon, 15 Aug 2016 13:48:22 -0700 (PDT)
Message-ID: <20160815.134822.386218604294575604.davem@davemloft.net>
References: <1471276123-24264-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@linuxdriverproject.org,
	linux-kernel@vger.kernel.org, haiyangz@microsoft.com,
	kys@microsoft.com, stephen@networkplumber.org
To: vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471276123-24264-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Mon, 15 Aug 2016 17:48:38 +0200

> Kernel crash is reported after VF is removed and detached from netvsc
> device. Turns out we have multiple different (but related) issues on the
> VF removal path which I'm trying to address with PATCHes 2-5 of this
> series. PATCH1 is required to support the change.
> 
> Changes since v1:
> - Re-arrange patches in the series to not introduce new issues [David Miller]
> - Add PATCH5 which fixes a new issue I discovered while testing.
> - Add Haiyang' A-b tags to PATCH1-4
> 
> With regards to Stephen's suggestion: I believe that switching to using RCU
> and eliminating vf_use_cnt/vf_inject is the right thing to do long-term, we
> can either put this on top of this series or do it later in net-next.

Series applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] wan: dscc4: use msecs_to_jiffies for conversions
Date: Sun, 07 Jun 2015 23:46:25 -0700 (PDT)
Message-ID: <20150607.234625.611646802904960429.davem@davemloft.net>
References: <1433673346-22183-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433673346-22183-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Sun,  7 Jun 2015 12:35:46 +0200

> API compliance scanning with coccinelle flagged:
> ./drivers/net/wan/dscc4.c:1036:1-33:
>         WARNING: timeout (10) seems HZ dependent
> ./drivers/net/wan/dscc4.c:554:2-34:
>         WARNING: timeout (10) seems HZ dependent
> ./drivers/net/wan/dscc4.c:599:2-34:
>         WARNING: timeout (10) seems HZ dependent
> 
> Numeric constants passed to schedule_timeout_*() make the effective
> timeout HZ dependent which does not seem to be the intent here.
> Fixed up by converting the constant to jiffies with msecs_to_jiffies(),
> passing 100ms (assuming HZ==100 in the original code).
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] net: thunderx: Setting IRQ affinity hints and
 other optimizations
Date: Thu, 11 Feb 2016 11:30:53 -0500 (EST)
Message-ID: <20160211.113053.1221794797998213409.davem@davemloft.net>
References: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com,
	robert.richter@caviumnetworks.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sunil.kovvuri@gmail.com
Date: Thu, 11 Feb 2016 21:50:20 +0530

> This patch series contains changes
> - To add support for virtual function's irq affinity hint
> - Replace napi_schedule() with napi_schedule_irqoff()
> - Reduce page allocation overhead by allocating pages
>   of higher order when pagesize is 4KB.
> - Add couple of stats which helps in debugging
> - Some miscellaneous changes to BGX driver.
> 
> Changes from v1:
> - As suggested changed MAC address invalid log message 
>   to dev_err() instead of dev_warn().

Series applied, thanks.

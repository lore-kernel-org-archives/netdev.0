From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/10] use appropriate APIs to get
 interfaces
Date: Tue, 14 Jan 2014 18:53:19 -0800 (PST)
Message-ID: <20140114.185319.701097353751396242.davem@davemloft.net>
References: <1389752625-23189-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, john.r.fastabend@intel.com,
	stephen@networkplumber.org, antonio@meshcoding.com,
	dmitry.tarnyagin@lockless.no, socketcan@hartkopp.net,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389752625-23189-1-git-send-email-ying.xue@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 15 Jan 2014 10:23:35 +0800

> Under rtnl_lock protection, we should use __dev_get_name/index()
> rather than dev_get_name()/index() to find interface handlers
> because the former interfaces can help us avoid to change interface
> reference counter.
> 
> v2 changes:
>  - Change return value of nl80211_set_wiphy() to 0 in patch #10
>    by johannes's suggestion.
>  - Add 'Acked-by' into several patches which were acknowledged by
>    corresponding maintainers.

This looks fine, series applied, thanks.

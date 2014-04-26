From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inetpeer_gc_worker: trivial cleanup
Date: Sat, 26 Apr 2014 12:53:02 -0400 (EDT)
Message-ID: <20140426.125302.2231088219056320790.davem@davemloft.net>
References: <1398387209-12322-1-git-send-email-jin.xiao@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, trivial@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, david.a.cohen@linux.intel.com
To: jin.xiao@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398387209-12322-1-git-send-email-jin.xiao@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiao jin <jin.xiao@intel.com>
Date: Fri, 25 Apr 2014 08:53:29 +0800

> Do not initialize list twice.
> list_replace_init() already takes care of initializing list.
> We don't need to initialize it with LIST_HEAD() beforehand.
> 
> Signed-off-by: xiao jin <jin.xiao@intel.com>
> Reviewed-by: David Cohen <david.a.cohen@linux.intel.com>

Also applied, thank you.

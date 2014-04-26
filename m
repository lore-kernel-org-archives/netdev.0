From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cleanup_net: trivial cleanup
Date: Sat, 26 Apr 2014 12:52:06 -0400 (EDT)
Message-ID: <20140426.125206.1284988815126862472.davem@davemloft.net>
References: <1398387054-11172-1-git-send-email-jin.xiao@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, ebiederm@xmission.com, dhowells@redhat.com,
	viro@zeniv.linux.org.uk, serge.hallyn@canonical.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	david.a.cohen@linux.intel.com
To: jin.xiao@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398387054-11172-1-git-send-email-jin.xiao@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiao jin <jin.xiao@intel.com>
Date: Fri, 25 Apr 2014 08:50:54 +0800

> Do not initialize net_kill_list twice.
> list_replace_init() already takes care of initializing net_kill_list.
> We don't need to initialize it with LIST_HEAD() beforehand.
> 
> Signed-off-by: xiao jin <jin.xiao@intel.com>
> Reviewed-by: David Cohen <david.a.cohen@linux.intel.com>

Applied, thank you.

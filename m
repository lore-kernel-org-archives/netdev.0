From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]IPv6: Acquire addrconf_hash_lock for reading instead of
 writing in addrconf_verify(...)
Date: Fri, 18 Nov 2005 15:51:01 -0800 (PST)
Message-ID: <20051118.155101.51861744.davem@davemloft.net>
References: <437BE773.6010007@21cn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751235AbVKRXux@vger.kernel.org>
To: yanzheng@21cn.com
In-Reply-To: <437BE773.6010007@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yan Zheng <yanzheng@21cn.com>
Date: Thu, 17 Nov 2005 10:14:11 +0800

> addrconf_verify(...) only traverse address hash table when addrconf_hash_lock is held
> for writing, and it may hold addrconf_hash_lock for a long time. So I think it's better
> to acquire addrconf_hash_lock for reading instead of  writing
> 
> Signed-off-by: Yan Zheng <yanzheng@21cn.com>

Applied, thanks Yan.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] include/net/inet_connection_sock.h: Use pr_devel()
 instead of pr_debug()
Date: Thu, 10 Mar 2016 16:14:49 -0500 (EST)
Message-ID: <20160310.161449.350898270672488267.davem@davemloft.net>
References: <1457416348-32463-1-git-send-email-nwang@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: whs_alex@163.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nwang@suse.de
To: nwang@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457416348-32463-1-git-send-email-nwang@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Wang <nwang@suse.com>
Date: Tue,  8 Mar 2016 13:52:28 +0800

> File "inet_connection_sock.h" is a common share header that not can 
> be use for one module, so use pr_devel instead of pr_debug is OK.

Not really, we only want these printks to do anything only when debug
printk's are enabled.

We don't want the overhead otherwise.

You'll need to find another fix for this, sorry.

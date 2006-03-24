From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] ip_conntrack_helper_h323.c: EXPORT_SYMBOL'ed
 functions shouldn't be static
Date: Thu, 23 Mar 2006 16:13:14 -0800 (PST)
Message-ID: <20060323.161314.59991770.davem@davemloft.net>
References: <20060324000801.GM22727@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zhaojignmin@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422733AbWCXARl@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060324000801.GM22727@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 24 Mar 2006 01:08:01 +0100

> EXPORT_SYMBOL'ed functions shouldn't be static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Fixed in Linus's tree as of yesterday.

I actually have a patch from Patrick McHardy that will make
this kind of error a build time failure instead of silently
working in the modular case.  I just need to test it out
a bit before pushing.

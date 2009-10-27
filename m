From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dcache: better name hash function
Date: Mon, 26 Oct 2009 22:24:28 -0700 (PDT)
Message-ID: <20091026.222428.80364204.davem@davemloft.net>
References: <9986527.24561256620662709.JavaMail.root@tahiti.vyatta.com>
	<19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, opurdila@ixiacom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
To: stephen.hemminger@vyatta.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755238AbZJ0FYH@vger.kernel.org>
In-Reply-To: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Mon, 26 Oct 2009 22:19:44 -0700 (PDT)

> How important is saving the one division, versus getting better
> distribution.

80 cpu cycles or more on some processors.  Cheaper to use
jenkins with a power-of-2 sized hash.

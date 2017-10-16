From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: Use normal debugging style
Date: Mon, 16 Oct 2017 21:14:14 +0100 (WEST)
Message-ID: <20171016.211414.1286262720433234705.davem@davemloft.net>
References: <1507935733-18950-3-git-send-email-dsahern@gmail.com>
        <9b7a23d78aff76a0d1e9078715e9932c9ba57b43.1508085878.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, dsahern@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9b7a23d78aff76a0d1e9078715e9932c9ba57b43.1508085878.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 15 Oct 2017 09:49:10 -0700

> Remove local ADBG macro and use netdev_dbg/pr_debug
> 
> Miscellanea:
> 
> o Remove unnecessary debug message after allocation failure as there
>   already is a dump_stack() on the failure paths
> o Leave the allocation failure message on snmp6_alloc_dev as there
>   is one code path that does not do a dump_stack()
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Joe please resubmit this when/if David's changes get applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix an infoleak in tipc_nl_compat_link_dump
Date: Thu, 02 Jun 2016 21:32:57 -0700 (PDT)
Message-ID: <20160602.213257.846438393853856990.davem@davemloft.net>
References: <1464854696-29513-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	taesoo@gatech.edu, csong84@gatech.edu, kjlu@gatech.edu
To: kangjielu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464854696-29513-1-git-send-email-kjlu@gatech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kangjie Lu <kangjielu@gmail.com>
Date: Thu,  2 Jun 2016 04:04:56 -0400

> link_info.str is a char array of size 60. Memory after the NULL
> byte is not initialized. Sending the whole object out can cause
> a leak.
> 
> Signed-off-by: Kangjie Lu <kjlu@gatech.edu>

Applied.

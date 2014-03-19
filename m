From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rcu: Replace rcu_assign_pointer(x, NULL) with
 RCU_INIT_POINTER(x, NULL)
Date: Wed, 19 Mar 2014 16:30:09 -0400 (EDT)
Message-ID: <20140319.163009.460997858507816239.davem@davemloft.net>
References: <1395180150-18548-1-git-send-email-monamagarwal123@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eddie.wai@broadcom.com, paulmck@linux.vnet.ibm.com
To: monamagarwal123@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395180150-18548-1-git-send-email-monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Many of your patches, such as this one, all have the same exact
subject line.

This makes it impossible to scan the subject lines and have some
idea what area a commit makes changes.

I would really suggest that you use a subject prefix that references
the driver or subsystem, so for this one:

Subject: [PATCH N/M] infiniband: Use rcu_assign_pointer(x, NULL instead) of RCU_INIT_POINTER(x, NULL)

and likewise for all of your other patches.

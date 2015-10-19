From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] RDS: convert bind hash table to re-sizable
 hashtable
Date: Sun, 18 Oct 2015 18:56:24 -0700 (PDT)
Message-ID: <20151018.185624.521387334647995840.davem@davemloft.net>
References: <1444857331-4344-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org, David.Laight@ACULAB.COM
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444857331-4344-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Wed, 14 Oct 2015 14:15:31 -0700

> From: Santosh Shilimkar <ssantosh@kernel.org>
> 
> To further improve the RDS connection scalabilty on massive systems
> where number of sockets grows into tens of thousands  of sockets, there
> is a need of larger bind hashtable. Pre-allocated 8K or 16K table is
> not very flexible in terms of memory utilisation. The rhashtable
> infrastructure gives us the flexibility to grow the hashtbable based
> on use and also comes up with inbuilt efficient bucket(chain) handling.
> 
> Cc: David Laight <David.Laight@ACULAB.COM>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

This looks fine as far as I can tell.

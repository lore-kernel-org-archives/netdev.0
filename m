From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] RDS: convert bind hash table to re-sizable
 hashtable
Date: Mon, 02 Nov 2015 15:36:55 -0500 (EST)
Message-ID: <20151102.153655.1301864027648808208.davem@davemloft.net>
References: <1446220150-3622-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446220150-3622-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Fri, 30 Oct 2015 08:49:10 -0700

> To further improve the RDS connection scalabilty on massive systems
> where number of sockets grows into tens of thousands  of sockets, there
> is a need of larger bind hashtable. Pre-allocated 8K or 16K table is
> not very flexible in terms of memory utilisation. The rhashtable
> infrastructure gives us the flexibility to grow the hashtbable based
> on use and also comes up with inbuilt efficient bucket(chain) handling.
> 
> Reviewed-by: David Miller <davem@davemloft.net>
> Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> ---
> v2: Dropped empty new line from rds_add_bound()  (David Miller)

Applied.

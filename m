From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 05/15] RDS: increase size of hash-table to 8K
Date: Mon, 21 Sep 2015 08:31:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB9BCF3@AcuExch.aculab.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
 <1442703892-26692-6-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ssantosh@kernel.org" <ssantosh@kernel.org>
To: 'Santosh Shilimkar' <santosh.shilimkar@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442703892-26692-6-git-send-email-santosh.shilimkar@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar
> Sent: 20 September 2015 00:05
> Even with per bucket locking scheme, in a massive parallel
> system with active rds sockets which could be in excess of multiple
> of 10K, rds_bin_lookup() workload is siginificant because of smaller
> hashtable size.
> 
> With some tests, it was found that we get modest but still nice
> reduction in rds_bind_lookup with bigger bucket.
> 
> 	Hashtable	Baseline(1k)	Delta
> 	2048:		8.28%     	-2.45%
> 	4096:		8.28%		-4.60%
> 	8192:		8.28%		-6.46%
> 	16384:		8.28%		-6.75%
> 
> Based on the data, we set 8K as the bind hash-table size.

Can't you use of on the dynamically sizing hash tables?
8k hash table entries is OTT for a lot of systems.

	David

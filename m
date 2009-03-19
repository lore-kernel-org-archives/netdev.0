From: Andi Kleen <andi@firstfloor.org>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 19 Mar 2009 14:45:40 +0100
Message-ID: <20090319134540.GW11935@one.firstfloor.org>
References: <49C16D7C.3080003@novell.com> <20090318.180355.228447835.davem@davemloft.net> <1237425191.8204.41.camel@quadrophenia.thebigcorporation.com> <20090318.181713.62394874.davem@davemloft.net> <1237427007.8204.55.camel@quadrophenia.thebigcorporation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ghaskins@novell.com,
	vernux@us.ibm.com, andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org,
	pmullaney@novell.com
To: Sven-Thorsten Dietrich <sven@thebigcorporation.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1237427007.8204.55.camel@quadrophenia.thebigcorporation.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Do we have to rule-out per-CPU queues, that aggregate into a master
> queue in a batch-wise manner? 

TSO/GSO/USO is that actually in a very specific way. It batches
packets into larger packets and then less per packet locks need to be taken.  
It was unclear if that was used in this workload or not.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

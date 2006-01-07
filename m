From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 23:44:40 -0800 (PST)
Message-ID: <20060106.234440.53993868.davem@davemloft.net>
References: <20060106.161721.124249301.davem@davemloft.net>
	<200601070209.02157.ak@suse.de>
	<43BF6F0B.4060108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, paulmck@us.ibm.com, alan@lxorguk.ukuu.org.uk,
	torvalds@osdl.org, linux-kernel@vger.kernel.org,
	dipankar@in.ibm.com, manfred@colorfullife.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030487AbWAGHrD@vger.kernel.org>
To: dada1@cosmosbay.com
In-Reply-To: <43BF6F0B.4060108@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 07 Jan 2006 08:34:35 +0100

> I agree, I do use a hashed spinlock array on my local tree for TCP,
> mainly to reduce the hash table size by a 2 factor.

So what do you think about going to a single spinlock for the
routing cache?

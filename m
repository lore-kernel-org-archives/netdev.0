From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] ipv6: fix the reassembly expire code in
 nf_conntrack
Date: Mon, 17 Sep 2012 22:53:04 -0400 (EDT)
Message-ID: <20120917.225304.1071254088219136410.davem@davemloft.net>
References: <1347935656.14402.12.camel@cr0>
	<20120917.223559.1226100441781312938.davem@davemloft.net>
	<1347936443.14402.15.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: amwang@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1347936443.14402.15.camel@cr0>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Tue, 18 Sep 2012 10:47:23 +0800

> I will remove this #ifdef and resend the whole patchset.

Or, alternatively, use IS_ENABLED() or a similar test which will take
the modular case into account.


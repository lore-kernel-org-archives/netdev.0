From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 19 Jun 2013 20:37:12 -0700 (PDT)
Message-ID: <20130619.203712.1274791928658538966.davem@davemloft.net>
References: <20130620125823.da633b21e33688372729b9c0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, johannes.berg@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130620125823.da633b21e33688372729b9c0@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 20 Jun 2013 12:58:23 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> net/wireless/nl80211.c between commit 3a5a423bb958 ("nl80211: fix attrbuf
> access race by allocating a separate one") from the net tree and commit
> 5fe231e87372 ("cfg80211: vastly simplify locking") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

I did this merge a few hours ago and hit the same conflict.

Although I fixed the bug in that rtnl_unlock() is not performed in
all the return code paths.

From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Tue, 23 Sep 2014 21:58:58 -0400 (EDT)
Message-ID: <20140923.215858.1862286673062032624.davem@davemloft.net>
References: <541A28BA.1060201@infradead.org>
	<54218AEF.5090200@suse.cz>
	<20140924072306.799005a3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mmarek@suse.cz, rdunlap@infradead.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-kbuild@vger.kernel.org, torvalds@linux-foundation.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140924072306.799005a3@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 24 Sep 2014 07:23:06 +1000

> Dave, this is a bit slack of you since I reported that problem a week
> ago in the net tree and yet it has not been completely fixed before you
> asked Linus to pull your tree :-(

There were build failures I saw due to some misbalanced select/depends
issues which I fixed in:

commit df568d8e5250bf24e38c69ad4374baf0f8d279ba
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Sep 22 13:14:33 2014 -0400

    scsi: Use 'depends' with LIBFC instead of 'select'.

which went in yesterday.  I thought that would resolve all of your
problems.

Believe me, it is a tragic surprise that several defconfigs absolutely
depended upon this broken usage of select in the scsi layer, to of all
things make CONFIG_NET=y implicit.

I'll do my best to sort this out, but I hope that this short term pain
is worth it in the end.

Thanks for your understanding.

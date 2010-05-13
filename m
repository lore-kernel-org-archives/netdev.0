From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocationAPIs
Date: Thu, 13 May 2010 22:36:51 +0900
Message-ID: <201005132236.ADJ57893.FLFFMtOVJHOOSQ@I-love.SAKURA.ne.jp>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
	<1273756816.5605.3547.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, hnguyen@de.ibm.com, raisch@de.ibm.com,
	rolandd@cisco.com, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	divy@chelsio.com, James.Bottomley@suse.de, tytso@mit.edu,
	adilger@sun.com, viro@zeniv.linux.org.uk, menage@google.com,
	lizf@cn.fujitsu.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	containers@lists.linux-foundation.org, eric.dumazet@gmail.com
To: peterz@infradead.org, xiaosuo@gmail.com
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <1273756816.5605.3547.camel@twins>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra wrote:
> NAK, I really utterly dislike that inatomic argument. The alloc side
> doesn't function in atomic context either. Please keep the thing
> symmetric in that regards.

Excuse me. kmalloc(GFP_KERNEL) may sleep (and therefore cannot be used in
atomic context). However, kfree() for memory allocated with kmalloc(GFP_KERNEL)
never sleep (and therefore can be used in atomic context).
Why kmalloc() and kfree() are NOT kept symmetric?

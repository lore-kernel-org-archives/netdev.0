From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vfs: dont chain pipe/anon/socket on superblock s_inodes
 list
Date: Tue, 26 Jul 2011 05:42:04 -0400
Message-ID: <20110726094204.GA12086@infradead.org>
References: <20110721204042.GB31405@ZenIV.linux.org.uk>
 <1311294452.2576.18.camel@schen9-DESK>
 <20110723132411.GA22183@infradead.org>
 <1311633550.2576.33.camel@schen9-DESK>
 <20110725225154.GD22133@ZenIV.linux.org.uk>
 <1311636178.2576.34.camel@schen9-DESK>
 <1311660013.2996.6.camel@edumazet-laptop>
 <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110726090357.GA13013@infradead.org>
 <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Anton Blanchard <anton@samba.org>, npiggin@kernel.dk,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2011 at 11:36:34AM +0200, Eric Dumazet wrote:
> [PATCH v2] vfs: dont chain pipe/anon/socket on superblock s_inodes list
> 
> Workloads using pipes and sockets hit inode_sb_list_lock contention.
> 
> superblock s_inodes list is needed for quota, dirty, pagecache and
> fsnotify management. pipe/anon/socket fs are clearly not candidates for
> these.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good to me,

Reviewed-by: Christoph Hellwig <hch@lst.de>


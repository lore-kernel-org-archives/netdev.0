From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] vfs: avoid taking locks if inode not in lists
Date: Wed, 27 Jul 2011 22:59:57 +0200
Message-ID: <20110727205957.GC8006@one.firstfloor.org>
References: <20110723132411.GA22183@infradead.org> <1311633550.2576.33.camel@schen9-DESK> <20110725225154.GD22133@ZenIV.linux.org.uk> <1311636178.2576.34.camel@schen9-DESK> <1311660013.2996.6.camel@edumazet-laptop> <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20110726090357.GA13013@infradead.org> <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1311780065.2356.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20110727204415.GA13308@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Anton Blanchard <anton@samba.org>, npiggin@kernel.dk,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110727204415.GA13308@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Btw, I wonder if you should micro-optimize things a bit further by
> moving the unhashed checks from the deletion functions into the callers
> and thus save a function call for each of them.

If the caller is in the same file modern gcc is able to do that automatically
if you're lucky enough ("partial inlining")

I would not uglify the code for it.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

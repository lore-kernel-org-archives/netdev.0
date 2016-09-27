From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Tue, 27 Sep 2016 06:34:04 -0700
Message-ID: <1474983244.28155.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160922164359.9035-1-vbabka@suse.cz>
	 <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
	 <1474940324.28155.44.camel@edumazet-glaptop3.roam.corp.google.com>
	 <6e62a278-4ac3-a866-51c6-e32511406aba@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro
 <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko
 <mhocko@kernel.org>,  netdev@vger.kernel.org
To: Vlastimil Babka <vbabka@suse.cz>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <6e62a278-4ac3-a866-51c6-e32511406aba@suse.cz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-27 at 10:13 +0200, Vlastimil Babka wrote:

> I doubt anyone runs that in production, especially if performance is of concern.
> 

I doubt anyone serious runs select() on a large fd set in production.

Last time I used it was in last century.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

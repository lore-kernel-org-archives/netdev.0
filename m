From: David Miller <davem@davemloft.net>
Subject: Re: [1/3] 2.6.21-rc6: known regressions
Date: Fri, 13 Apr 2007 21:25:03 -0700 (PDT)
Message-ID: <20070413.212503.121306001.davem@davemloft.net>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
	<20070414003625.GS5907@stusta.de>
	<Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bunk@stusta.de, greg@kroah.com,
	davej@redhat.com, akpm@linux-foundation.org, jgarzik@pobox.com,
	mingo@elte.hu
To: torvalds@linux-foundation.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 13 Apr 2007 18:34:23 -0700 (PDT)

> Davem - have there been network infrastructure changes that migt be 
> suspect? Jeff and/or Greg - anything in the generic network driver/device 
> driver level? We had some trouble earlier with the transition to the 
> driver core, and kref miscounting. Related? The last Oops Ingo saw was a 
> module refcounting one, iirc.

Nothing stands out in the recent changes I've merged, I'll study this
issue and see if I can see any pattern or a clue.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [1/3] 2.6.21-rc6: known regressions
Date: Fri, 20 Apr 2007 15:39:52 +0200
Message-ID: <20070420133952.GA17749@elte.hu>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
	<20070414003625.GS5907@stusta.de>
	<Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
	<20070414062143.GA12707@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Adrian Bunk <bunk@stusta.de>, Greg KH <greg@kroah.com>,
	Dave Jones <davej@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20070414062143.GA12707@elte.hu>
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


* Ingo Molnar <mingo@elte.hu> wrote:

> > The 6b6b6b6b pattern is POISON_FREE, implying some kind of slab 
> > misuse, most likely a use-after-free, although possibly just due to 
> > overrunning a slab into the next one or something like that.
> 
> unfortunately, while being at -rc6 based kernel #445 meanwhile, this 
> incident was the only time i saw this problem. [...]

meanwhile i'm at kernel bootup #657, and still this crash did not 
reoccur. So it could have been some pre-existing sysfs bug that triggers 
only extremely rarely. I'd suggest that this bug have its priority 
lowered (to not hold up a v2.6.21 release) - there's no smoking gun and 
no reproducer. I'll keep an eye on it.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

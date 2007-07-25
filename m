From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [-mm patch] one e1000 driver should be enough for
	everyone
Date: Wed, 25 Jul 2007 09:48:55 -0400
Message-ID: <46A754C7.9080004@garzik.org>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<20070725133650.GB3572@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Auke Kok <auke-jan.h.kok@intel.com>, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070725133650.GB3572@stusta.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> BTW:
> Unless I'm misunderstanding anything, the new driver should support a 
> superset of what the old driver supported.
> Therefore, it would be good if the final merge into Linus' tree will
> do an
>   rm -r drivers/net/e1000
>   mv drivers/net/e1000new drivers/net/e1000

Based on the most recent discussion, e1000new (or whatever it will be 
called) should support only the newer PCI-Express chips, while e1000 
will retain support for the older chips.

Over the long term this will allow e1000new to grow without affecting 
support for the older, stable chips.

So, e1000 is not going away.

	Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/

From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [Q] How to invalidate ARP cache for a network device from
	within kernel
Date: Sat, 27 Nov 2010 02:18:33 +0100
Message-ID: <20101127021833.328e8942@stein>
References: <1290793099.3716.21.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux1394-devel <linux1394-devel@lists.sourceforge.net>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1290793099.3716.21.camel@maxim-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Nov 26 Maxim Levitsky wrote:
> However as soon as bus reset happens, the upper layer ARP cache isn't
> invalidated, thus all attempts to send packets to remote node now fail,
> because the additional information (node id and bus address) about
> remote node is now invalid, but ARP core doesn't send ARP requests
> because it has the response in the cache.

When is this a problem?  With nodes which stay on the bus (i.e. are
present before and after the bus reset)?  Or with nodes which go away
and come back much later (but before the old ARP cache entry was cleaned
out)?
-- 
Stefan Richter
-=====-==-=- =-== ==-==
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Increase Visibility of Your 3D Game App & Earn a Chance To Win $500!
Tap into the largest installed PC base & get more eyes on your game by
optimizing for Intel(R) Graphics Technology. Get started today with the
Intel(R) Software Partner Program. Five $500 cash prizes are up for grabs.
http://p.sf.net/sfu/intelisp-dev2dev

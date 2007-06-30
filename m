From: Jeff Garzik <jeff@garzik.org>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 20:09:35 -0400
Message-ID: <46859F3F.305@garzik.org>
References: <1183138159.17243.16.camel@blaa>	
	<20070629175006.GB3917@falooley.org>
	<468571C6.3090305@garzik.org>	 <46857C08.4030303@intel.com>	
	<20070629150350.414553d4.akpm@linux-foundation.org>	
	<4685838D.9080108@garzik.org>
	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
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

Andrew Grover wrote:
> I think making e1000new ICH9-and-newer isn't really the best place to
> split it. The Windows e1000 driver got split on the PCI->PCIe
> transition, something that clearly delineated what nics one driver
> supported, and the other. There's no real technical reason for
> splitting now other than "this was when e1000old collapsed under its
> own weight".
> 
> The PCIe adapters are also the first ones to support multiple queues
> IIRC, maybe that would be an another actual technical reason to split
> it there?

Can knowledgeable people characterize the PCIe adapters somehow?  Is 
that "ICH8-era and later", or does it go back further than that?

	Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

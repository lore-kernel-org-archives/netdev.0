From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9
 support from 7.5.5 ?)
Date: Mon, 09 Jul 2007 13:56:59 -0400
Message-ID: <469276EB.4090502@garzik.org>
References: <46857C08.4030303@intel.com>
	<20070630082520.GA20140@infradead.org>	
	<468AD23A.4090904@intel.com> <468D8B32.9020305@garzik.org>	
	<468EDAF9.3020606@intel.com>	
	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	
	<46900B83.1060902@intel.com>	
	<20070707183244.19d21893@freepuppy.rosehill.hemminger.net>	
	<469110F6.2030902@linux.intel.com> <4691279C.8030603@garzik.org>
	<c0a09e5c0707081224o5dd34da6m2a1c16f4a2b4f59d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <c0a09e5c0707081224o5dd34da6m2a1c16f4a2b4f59d@mail.gmail.com>
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
> On 7/8/07, Jeff Garzik <jeff@garzik.org> wrote:
>> * e1000 gets feedback
>> * Intel disappears for months
>> * Intel reappears with e1000 rewrite
> 
> * you ask them for another complete (simpler) rewrite
> 
>> * Intel fights tooth and nail when the driver is not accepted verboten
> 
> I don't think it must be as-is (i.e. replacing e1000 for all HW) but
> don't throw away all the work they've done in architecting the driver
> to cleanly handle multiple chip generations.
> 
> How about:
> 
> 1) Considering e1000new's current design, but for ICH9 only
> 2) test test test
> 3) Sometime in the future, considering incrementally moving previous
> PCIe generations' support from e1000 to e1000new (like I initially
> wanted, since that at least means there would be some technical reason
> for where the split occurs :-)

That plan would be fine...  as long as the e1000new driver internals 
were restructured as I've been describing.

If one arrives at a driver containing an internal API that is flexible 
enough to implement support for almost -any- NIC, then that's a sign 
that it needs to be organized in a different fashion.

	Jeff




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

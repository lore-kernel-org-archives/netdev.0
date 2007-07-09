From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9
 support from 7.5.5 ?)
Date: Mon, 09 Jul 2007 18:26:25 -0400
Message-ID: <4692B611.1050603@garzik.org>
References: <46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org>	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	<46859F3F.305@garzik.org>	<4685C09B.7040908@intel.com>	<20070630082520.GA20140@infradead.org>	<468AD23A.4090904@intel.com>	<468D8B32.9020305@garzik.org>	<468EDAF9.3020606@intel.com>	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	<46900B83.1060902@intel.com>
	<20070707183244.19d21893@freepuppy.rosehill.hemminger.net>
	<469110F6.2030902@linux.intel.com> <4691279C.8030603@garzik.org>
	<46914382.8090801@linux.intel.com>
	<469280F5.8000909@garzik.org> <46929EBB.3000809@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	Andrew Grover <andy.grover@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46929EBB.3000809@intel.com>
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

Kok, Auke wrote:
> I would strongly vote for taking a stripped down e1000new then, mask out 
> all the pci id's except ich9, remove all code for pre-pci-e silicon and 
> remove the most annoying and needlessly complexing code like the 
> semi-implemented multiqueue code that is in there.

I'm fine for that as a path forward.  I would think that would zap a lot 
of the hooks.


> How we are going to improve the internal api then can subsequently be 
> done upstream in steps: implement using phylib, reorganize the code. 
> This would give the community a view on the progress.
> 
> I fear that if I spend yet another 2 months offline working on making a 
> minimal ich9 driver I will lose even more time and patience: Even though 
> the current driver (with pre-pci-e stripped) might not be as nice as you 
> want, at least we can work together on it. I would rather go with 
> something I know that works, isn't too bad, and we have time and start 
> reviewing upstream immediately.

"minimal ich9 driver" is more a metaphor, describing the seed from which 
a clean driver would logically grow:  imagine a minimal ich9 driver, 
then add TSO, add support for other PCI-e phys, etc.  Whether you do 
this exercise in your head or on the computer makes no difference, as 
long as you can see what the end result should look like.

Not asking for yet another driver...  Start with e1000new or whatever 
base you like.  Post driver for review, get feedback, update, lather, 
rinse, repeat.  If we're all responsive, it should not take long at all 
to get something upstream-mergeable.  Solve the "big potato" issues 
especially :)


> Agreed. All current e1000 pci-e hardware is based on the same mac, so 
> it's the logical split. The differences are PHYs and manageability, but 

OK

	Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

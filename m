From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9
 support from 7.5.5 ?)
Date: Sun, 08 Jul 2007 09:29:42 -0700
Message-ID: <469110F6.2030902@linux.intel.com>
References: <46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org>	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	<46859F3F.305@garzik.org>	<4685C09B.7040908@intel.com>	<20070630082520.GA20140@infradead.org>	<468AD23A.4090904@intel.com>	<468D8B32.9020305@garzik.org>	<468EDAF9.3020606@intel.com>	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	<46900B83.1060902@intel.com>
	<20070707183244.19d21893@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Andrew Grover <andy.grover@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070707183244.19d21893@freepuppy.rosehill.hemminger.net>
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

Stephen Hemminger wrote:
>> I would really like to continue with my original plan that I posted that follows 
>> Christoph's idea. I hope you can all agree with that so we can get on with this.
> 
> I think rather than having a meta-discussion, which always seems to degenerate
> into finger pointing. Let's look at the code. The problem with popular drivers
> (as I too well know) is that user's seem to find every wart.  There are lots of
> old drivers that never seem to get the same scrutiny, and if they did would
> be tarred and feathered.


I'd second this; also lets be honest and fair about things and use a 
similar standard for all drivers; are we going to ask all driver 
submitters to remove NAPI, TSO and other stuff? I would hope not. Are 
all new drivers that have even a single bitfield going to be rejected? 
That's be a new rule but ok, if it applies to all drivers it's fair.

So the question in my opinion should be "is this driver good enough 
for merging, and if not, what specifically is wrong enough to hold of 
merging" not "what would the perfect ideal 
we-have-all-the-time-in-the-world driver be" and certainly not "how is 
this going to work in an enterprise distro" since the later is the 
problem for the enterprise disro that they get paid to solve, not for 
kernel.org kernels.

What is there now is a driver that works, is relatively clean (and yes 
if you look deep enough you can ALWAYS nitpick on any code, even 
Linus' or Jeff's best code) and provides good performance with all the 
features a modern ethernet driver is supposed to have.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

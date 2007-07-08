From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9
 support from 7.5.5 ?)
Date: Sat, 7 Jul 2007 18:32:44 -0700
Message-ID: <20070707183244.19d21893@freepuppy.rosehill.hemminger.net>
References: <46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org>
	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
	<46859F3F.305@garzik.org> <4685C09B.7040908@intel.com>
	<20070630082520.GA20140@infradead.org> <468AD23A.4090904@intel.com>
	<468D8B32.9020305@garzik.org> <468EDAF9.3020606@intel.com>
	<20070707190431.GA26341@electric-eye.fr.zoreil.com>
	<46900B83.1060902@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	Christoph@sc8-sf-spam2.sourceforge.net,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew@sc8-sf-spam2.sourceforge.net,
	"David S.  Miller" <davem@davemloft.net>,
	Hellwig <hch@infradead.org>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Andrew Grover <andy.grover@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Morton <akpm@linux-foundation.org>,
	van de Ven <arjan@linux.intel.com>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arjan@sc8-sf-spam2.sourceforge.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46900B83.1060902@intel.com>
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

On Sat, 07 Jul 2007 14:54:11 -0700
"Kok, Auke" <auke-jan.h.kok@intel.com> wrote:

> Francois Romieu wrote:
> > Kok, Auke <auke-jan.h.kok@intel.com> :
> >> Jeff Garzik wrote:
> >>> Kok, Auke wrote:
> > [...]
> >> This is not acceptable and hardly fair to expect from us.
> >>
> >> It also exposes users to endless delays and uncertainties as to a final 
> >> resolution. Not to mention that writing a driver from scratch for (just) 
> >> ich9 will take significant time, is silly since it's almost identical to 
> >> ich8 etc..
> >>
> >> I don't think that anyone besides you and maybe one or two others are 
> >> interested in doing this rewrite from scratch.
> > 
> > So far I'd say him and at least two others. Is it time to count them ?
> > 
> > Everybody is cool and polite but after a week of discussion this is
> > going nowhere.
> 
> It is really hard to stay polite for me now. After we were told to clean up the 
> driver and implement things like feature flags and organize all the various 
> hardware dependent bits, we did exactly that. And now we're told to rewrite the 
> driver from scratch. ("thanks for the effort but no thanks, do this instead").
> 
> If that does not make your hair on the back of your neck stand up...
> 
> I politely suggested a middle way that would allows us to continue working on 
> the driver and take it to the next step. This would in my opinion be the least 
> destructive plan and get us moving forward quickly. Jeff's alternative plan can 
> set us back another year. Perhaps it won't, but I fear that it will, and it will 
>   be a hard thing to sell to my group and other parties.
> 
> I agree that rewriting drivers that are bad from scratch is a good thing. But in 
> this case we're talking about a driver with a good reputation that has 
> functioned really well for everyone for as long as it's out there. Perhaps you 
> disagree on this, but lets just agree on that e1000 never really broke in the 
> last 7 years even though we added over 50 different type of adapters to it, and 
> it's still performance wise a good driver.
> 
> As a matter of fact, I find it hard to believe that e1000 has a bad reputation. 
> Almost all of the direct feedback that I get from people using e1000 is 
> positive. We regularly get good feedback on our response rate too.
> 
> We as a group are committed to keep repairing and improving e1000 and I think 
> that we have shown our good intent with some of the stuff that we've recently 
> shown. I think it's also polite to let us do our work and work *with* us, 
> instead of dumping our ideas ("I like the gist of it, but") and basically 
> sending us off with nothing. And that means that the linux community also is 
> stuck with nothing.
> 
> I would really like to continue with my original plan that I posted that follows 
> Christoph's idea. I hope you can all agree with that so we can get on with this.

I think rather than having a meta-discussion, which always seems to degenerate
into finger pointing. Let's look at the code. The problem with popular drivers
(as I too well know) is that user's seem to find every wart.  There are lots of
old drivers that never seem to get the same scrutiny, and if they did would
be tarred and feathered.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Re: [Prism54] CVS -> bk tree update
Date: Wed, 16 Jun 2004 17:09:13 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <40D0B6F9.7020600@pobox.com>
References: <20040614191651.GC6253@ruslug.rutgers.edu>
	<40CE2754.1020109@pobox.com>
	<20040616022008.GM6253@ruslug.rutgers.edu>
	<40CFBA24.7030307@pobox.com>
	<20040616051103.GN6253@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
In-Reply-To: <20040616051103.GN6253@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> On Tue, Jun 15, 2004 at 11:10:28PM -0400, Jeff Garzik wrote:
>>Sorry, no.  You knew that split-up patches would be needed, once the 
>>initial driver merge is complete (which was complete before the most 
>>recent series of 17 patches).
> 
> 
> Actually no. I wasn't aware of how netdev patches went upstream until
> the driver got in and our first set of patches got rejected. After the
> driver got in the kernel the first set of patches was just to get the
> kernel tree up to speed with what *really* was current in our cvs tree
> (remember Jean was the one who submitted the original patch).
> 
> What occurred afterwards was more of a misunderstanding of what is
> acceptable and what is not for patches for network driver projects. I
> thought, since you had suggested to continue with the prism54 project,
> and submit a patch for our next release. No one on our dev team or 
> lists knew any better or didn't say much to make us think otherwise.

This is general Linux kernel development, nothing netdev specific about 
it (besides who the email goes to).

The details are in Documentation/SubmittingPatches.

Large "megapatches" are _always_ discouraged.  The only normal case 
where large patches are accepted is when adding new drivers.


>>This is one of the big downsides to developing in CVS, 
> 
> 
> <edit> for the kernel since what's mainly used by mantainers is
> bitkeeper </edit> 

Nope.  CVS specifically sucks above all other SCMs, including 
no-SCM-at-all :)

"subversion" and "arch" are up-and-coming open source competitors to 
BitKeeper, that are already 1000 times better than cvs.

I kept my kernel hacking in cvs for years 
(http://sf.net/projects/gkernel/) but I abandoned that before BitKeeper 
arrived, because CVS was simply the _wrong_ SCM for kernel development.

CVS does not have a good idea of what a "changeset" is, it only knows 
about individual file revisions.  CVS is a big fat hack :)  But nothing 
else was free and remotely usable at the time, so it caught on.


>>and it bites 
>>people again and again.
> 
> 
> CVS is used as a project repository, not *the linux kernel repository*. It would
> seem to me reasonable though that if a project is doing a good job in
> making sure code gets tested, keeping a tight bugzilla, cvs daily
> updates, a detailed changelog, and viewcvs, that a big patch sent out to
> kernel mantainers for a new driver project release version would just be
> accepted. Apparantly not and *this* is what sucks about using CVS -- the
> fact these rules for small patches exist, and that the kernel uses a
> different versioning system. And that's it.

Versioning system is irrelevant, it's the lack of changeset support in 
CVS that hurts the most.


>>Linux kernel development relies on split-up patches for review, testing, 
>> and narrowing down which patch in a series introduced a bug.  There 
>>are real, engineering-related reasons we do things this way.
> 
> 
> Don't get me wrong... I love this. I think that because of this is why
> we have such a great kernel. The problem here was that there was
> miscommunication between you, Jean, and us. The patch shouldn't have
> been accepted to include the driver into the kernel until 
> our main project goals were completed. We then did not know the details 
> on followup procedures to update netdev drivers, nor were we told.

Agreed, this was largely a problem of miscommunication.

For my part, I simply assumed that you guys knew the standard kernel 
procedure (Documentation/SubmittingPatches), since the first two steps 
were successful:
1) submit driver, and
2) submit follow-up changes as small, broken-up patches


> We've learned our lesson the hard way. Oh well. Just please warn others
> submitting new drivers too -- submit until you think you only have small
> changes left, and also integrate the driver by verifying first with the 
> mantainers (warn about patch policy, etc).

We mainly need to make sure people read Documentation/SubmittingDrivers 
and Documentation/SubmittingPatches...


> This also just makes me want to just consider using bitkeeper. What benefits are
> there for our project, would we be able to get write access, and how
> else would procedures change for us?

Bitkeeper is de-centralized, designed for massively distributed 
development.  The best way to answer your questions is to read 
Documentation/BK-usage/bk-kernel-howto.txt -- I wrote it, and it 
presents BitKeeper from a CVS point of view, for kernel hackers.

Food for thought:  There is no client/server in BitKeeper, each 
repository on disk it essentially its own branch.

As to submitting changes via BitKeeper, here is an example of me sending 
changes to Linus: 
http://seclists.org/lists/linux-kernel/2003/Dec/1166.html (that email is 
almost completely auto-generated)

	Jeff

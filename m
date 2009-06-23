From: Jake Edge <jake-T1hC0tSOHrs@public.gmane.org>
Subject: Re: [PATCH v3.1415] Documentation: add documentation summary for rc-series and merge window
Date: Tue, 23 Jun 2009 11:18:40 -0600
Message-ID: <m3fxdqj2bz.fsf@lwn.net>
References: <20090622222217.GH23972@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "corbet\@lwn.net" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"akpm\@linux-foundation.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan\@lxorguk.ukuu.org.uk" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata\@ab.jp.nec.com" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090622222217.GH23972-PfSpb0PWhxZc2C7mugBRk2EX/6BAtgUQ@public.gmane.org> (Luis R. Rodriguez's message of "Mon\, 22 Jun 2009 18\:22\:17 -0400")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org> writes:

Hi Luis,

A few comments:

> +2.0:SUMMARY
> +
> +This section provides a brief summary of the kernel release rules.

Is there a reason not to renumber this whole file, making this section
2.1 and incrementing everything else further down?  It just stands out
from the rest of the document by having a 2.0 section, as well as having
all of the 2.0.x subsections.  It's probably fairly minor, but it does
make this chunk look very different than the rest of the
development-process document ...

> +
> +2.0.0: KERNEL RELEASE RULES
> +
> +Stable kernels are released when they are ready! This means there are
> +absolutely no strict guidelines for sticking to specific dates for a
> +kernel release.

The bang (!) seems unneeded.

The second sentence seems to have an overabundance of modifiers, perhaps
something like: This means there are no strict guidelines, in terms of
specific dates, for a kernel release.

> +
> +2.0.1: PATCH QUEUING FOR THE NEXT KERNEL RELEASE
> +
> +Linus maintains the development kernel, this means he accepts new
> +features and drivers for the next kernel release. He however does not
> +maintain every single line of the kernel. The kernel is broken down by
> +different subsystems and each subsystem has its own maintainer. In order
> +to aid the development of Linux maintainers subsystem have trees where
> +they queue patches for the next kernel release. This is typically done
> +with a foo-next-2.6.git tree where foo would be an arbitrary subsystem
> +name. These trees typically are designed to have a clean git history
> +to make pulling for Linus easier and as clean as possible.

I don't quite follow: In order to aid the development of Linux
maintainers subsystem have trees ...

is there a missing comma and/or some missing words?

Is the "foo-next-2.6.git" convention that widespread?  It just seems
like subsystem maintainers have various ways they track things for the
next development release, but maybe I am wrong.  If not, though, perhaps
toning "typically done" down some, and using it as an example of how it
*might* be done, would be better.


> +
> +Subsystem maintainers can typically have their own development git trees
> +apart from the foo-next-2.6.git trees as a breeding ground and test ground
> +for bleeding edge patches. Subsystem maintainers are at complete freedom to
> +maintain these trees however they see fit. Once patches have been proven
> +stable enough in a development tree they tend to be moved to their
> +respective foo-next-2.6.git tree.

as a breeding and testing ground for bleeding edge patches. (sounds
better i think)

> +Subsystem development trees are *always* open for development and new patches
> +are always accepted. After a new kernel is released subsystem maintainers
> +tend to slow down in accepting patches into their development trees though
> +so that the new development can eventually be rebased easily ontop of the
> +next kernel rc1 release.

The first sentence seems to overstate the case somewhat ... new patches
are welcome most any time, not necessarily accepted ... I suspect (but
don't know for sure) that there are times when subsystem trees are
"closed" as well, but maybe not officially

> +If your patch is adding a new feature or changing a lot of code and you send
> +it between a stable kernel release and prior to the rc1 kernel release it will
> +likely be a while before it is merged into a development tree, so be patient
> +during this time.

"between a stable kernel release and prior to the rc1 kernel release"
sounds like "during the merge window"

> +After the merge window the kernel is worked on through the rc-series of the
> +kernel release. The rc-series focus is to address regressions. The merge window
> +closes upon the first rc-series release, rc1.

to address regressions and fix bugs introduced by the new features added
during the merge window.

> +After a subsystem maintainer has sent his pull request to Linus during the merge
> +window no further new development will be accepted for that foo-next-2.6.git
> +tree and as such it marks the closure of development for that subsystem for that
> +kernel cycle.

and, as such, it marks

> +Developers wishing to target deadlines should simply work on their development
> +without regards or consideration for inclusion to a specific kernel
> +release.

That seems a little strange to say ... if they wish to target deadlines,
they can't work without consideration for inclusion into a specific
kernel, can they?

I think you are trying to suggest that they *not* target deadlines, but
that if they must ...

> +A good indication of when the next stable kernel release will be made is when
> +Linus notes the last rc cycle released may be the last. By this time you
> +should already have all your development done and merged in the respective
> +development tree. If your code is not ready and merged into the respective
> +maintainers development tree prior to the announced last potential rc kernel
> +release chances are you missed getting your code in for the next kernel merge
> +window. Exemptions here are new drivers, covered below.

prior to the last rc kernel release, chances are ...

(Li Zefan had some corrections in here, that I won't repeat)

> +This section summarizes what kind of patches are accepted after a new stable kernel is
> +released, before the merge window closes and after it closes. These patches are targeted
> +for the kernel prior to its final release.

before and after the merge window closes.

These patches are targeted for the new kernel currently under
development. (or something like that, "targeted for the kernel prior to
its final release" doesn't make sense, at least to me)


> +Before the merge window closes, prior to the rc1 release, Linus accepts pull requests
> +from different subsystem maintainers, with it go all the queued up material for the
> +next kernel release for each respective subsystem, on all foo-next-2.6.git trees.

This could be simplified substantially: Before the merge window closes,
Linus accepts pull requests from the subsystem maintainers; these
contain all of the queued up patches for that subsystem that are bound
for the next kernel release.

> +After subsystem maintainers have sent their pull requests there are strict rules
> +for new patches prior to the close of the merge window, marked by the
> +rc1 release:

It doesn't seem like you need to keep stressing that the merge window
closes with -rc1 ... but maybe that's just me ...

> +
> + - patches must fix a regression
> + - patches must fix a security hole
> + - patches must fix a oops/kernel hang
> +
> +Non-intrusive bug fixes fixes will very likely not be accepted. Some maintainers
> +may choose to accept some non-intrusive patches, depending on their work load.
> +You should however not take it for granted such patches will get accepted. You
> +should always just target the development kernel and provide a good commit to
> +help with review.

I think you mean "intrusive bug fixes", but maybe not ... maybe the
distinction isn't on the intrusiveness, so much as how
critical/important the fix is ... this also seems overly concrete, in
that various maintainers have their own style which may or may not
conform to this ...

> +When in doubt consult with your subsystem maintainer or just allow him to
> +do the judging of where the patches deserves to go to, an excellent commit log
> +should help with this effort.

When in doubt, consult with the subsystem maintainer to determine
when the patch should be merged.  A well-written, concise commit log
message will help here.

> +Linus does not accept more pull requests from subsystem maintainers after the
> +rc1 release. This means you can expect no new features or new development after
> +rc1.

Again, seemingly too rigid based on what really happens ... but maybe
this is documenting the "ideal"

> +The same type of patches are accepted after the rc1 release with the addition
> +of a slight warmer welcome for non-intrusive bug fix patches. Non-intrusive
> +bug fixes must be important and address very clearly the bug they are fixing.
> +Non-intrusive bug fixes can fix issues which are not a regression, security
> +hole or a kernel oops/hang.
> +
> +Linus will not accept non-intrusive bug fix patches late in the rc-series, after
> +the rc5, for example.

Again, maybe it's just me, but this 'non-intrusive' distinction doesn't
read quite right ... I guess the problem is that non-intrusive and
regression/security/oops fixes are not mutually exclusive but this
document sometimes reads that way ... there are critical bug fixes that
will be accepted pretty much any time, no matter how intrusive they
are.  There are less critical bug fixes that will be accepted based on
how intrusive they are and where in the cycle the patch is proposed.

> +You should never take it for granted non-intrusive bug fixes will be accepted.

so, when do these non-intrusive bug fixes get accepted?  only pre-merge window?

> +The very first release a new driver or filesystem is special. New drivers
> +are accepted during the rc-series! Patches for the same driver then are
> +also accepted during the same rc-series of a kernel as well as fixes for it
> +cannot regress as no previous kernels exists with it.

No ! needed I don't think ....

> +After a driver has been present for one kernel release the relaxed rules for
> +it during the rc-series are no longer applicable.

except staging drivers?

> +	2.6.20	February 4, 2007 - 68

68 days I presume

jake

-- 
Jake Edge - jake-Nu8SLkwKf8VeoWH0uzbU5w@public.gmane.org - http://www.edge2.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

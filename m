From: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Fri, 19 Jun 2009 10:41:42 -0700
Message-ID: <dd18b0c30906191041l5aa09b73xc788af6d6ba7c24c@mail.gmail.com>
References: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com>
	 <20090615223206.GA4966@kroah.com> <20090616004122.GC5492@tesla>
	 <20090616021011.GF23972@bombadil.infradead.org>
	 <20090616032034.GA17932@kroah.com> <20090616042113.GA5680@tesla>
	 <20090616093401.GA11602@jm.kir.nu> <20090616181705.GB31506@tesla>
	 <20090619150015.GC1389@ucw.cz>
	 <43e72e890906191010v4b2e79a5x2c7b722b8209933c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Jouni Malinen <j@w1.fi>,
	Luis Rodriguez <Luis.Rodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "corbet-T1hC0tSOHrs@public.gmane.org" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <43e72e890906191010v4b2e79a5x2c7b722b8209933c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 19, 2009 at 10:10 AM, Luis R.
Rodriguez<lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org> wrote:
> On Fri, Jun 19, 2009 at 8:00 AM, Pavel Machek<pavel-+ZI9xUNit7I@public.gmane.org> wrote:
>> On Tue 2009-06-16 11:17:05, Luis R. Rodriguez wrote:
>>> On Tue, Jun 16, 2009 at 02:34:01AM -0700, Jouni Malinen wrote:
>>> > On Mon, Jun 15, 2009 at 09:21:14PM -0700, Luis R. Rodriguez wrote=
:
>>> >
>>> > > +2.0.2: RC-SERIES RULES
>>> > > +
>>> > > +Rules on what kind of patches are accepted after the merge win=
dow closes.
>>> > > +These are patches targeted for the kernel rc-series of a kerne=
l prior
>>> > > +to its release.
>>> > > +
>>> > > + - it must fix a reported regression
>>> > > + - if must fix a reported security hole
>>> > > + - if must fix a reported oops/kernel hang
>>> >
>>> >
>>> > s/if/it/ twice..
>>>
>>> Thanks, fixed.
>>>
>>> > Is there a good reason for documenting different rules for rc-ser=
ies and
>>> > -stable releases? These three rules look stricter than the ones
>>> > described in stable_kernel_rules.txt:
>>> >
>>> > =A0- It must fix a problem that causes a build error (but not for=
 things
>>> > =A0 =A0marked CONFIG_BROKEN), an oops, a hang, data corruption, a=
 real
>>> > =A0 =A0security issue, or some "oh, that's not good" issue. =A0In=
 short, something
>>> > =A0 =A0critical.
>>>
>>> The rc-series rules this patch adds are a summary, so they do indee=
d appear to be
>>> stricter but I do think new vendor/device ids should be welcomed as=
 well AFAICT,
>>> for instance.
>>>
>>> What may be best is to merge these two somehow and refer to the com=
mon rules for
>>> both and try to differentiate between them in their respective docu=
mentation
>>> section.
>>>
>>> But I also think good judgement can be applied, good judgement bein=
g defined as
>>> that of a subsystem maintainer, which allows us to simply tell deve=
lopers to
>>> focus on development and send patches up and the respective maintai=
ner routes
>>> the fixes accordingly.
>>>
>>> The spirit of writig this summary is to be clear that rules do exis=
t and that
>>> we cannot simply suggest to read stable_kernel_rules.txt as there a=
re items there
>>> which do not apply.
>>>
>>> Reason for trying to add more documentation for this is today there=
 are a lot
>>> companies are working upstream and a better sense of what can get i=
nto specific
>>> kernel releases becomes more important and you also have more respo=
nsible
>>> developers looking out to ensure their fixes get propagated to the =
right trees.
>>> So leaving some of these things undocumented, implied or in the dar=
k can turn
>>> out to not be as healthy and IMHO is what lead to the original issu=
e from which
>>> I extracted information to create this summary.
>>>
>>> > For example, a fix for data corruption that users can hit relativ=
ely
>>> > easily sounds like a good example of something that should really=
 be
>>> > accepted during the rc-phase even if it is not really a regressio=
n or
>>> > does not cause a kernel oops/hang.
>>>
>>> Agreed.
>>>
>>> > "oh, that's not good" issue is somewhat more difficult to comment=
 on,
>>> > but I would expect that there could be some critical issues that =
really
>>> > would benefit from an exception. What exactly would qualify is so=
mething
>>> > that may be not be easily described in a sentence or two, though.
>>> >
>>> >
>>> > The main problem I see with having a very hard line on not allowi=
ng
>>> > critical fixes (however that would be defined) during the rc-phas=
e is
>>> > that it will take quite a long time to get the fix eventually out=
=2E As an
>>> > example, a driver could have a bug that prevents it from working =
with
>>> > certain subset of devices, but this is noticed only couple of ker=
nel
>>> > releases after the initial driver merge (e.g., for hardware that =
was not
>>> > yet available for end users at the time the driver was initially
>>> > submitted).
>>>
>>> I believe it makes sense to send fixes for new hardware on an old
>>> driver if it is known the fix cannot regress as it does not affect =
older
>>> hardware.
>>>
>>> > In other words, the issue would not be a regression, not a
>>> > security hole, and not an oops/kernel hang. However, it could mak=
e the
>>> > driver unusable to large number of users (once the affected hardw=
are
>>> > model becomes available; say in a new laptop).
>>>
>>> Agreed. But I think that would fall under the new driver category.
>>>
>>> > If an issue is fixed just before a start of the next merge window=
 the
>>> > patch may not have had enough time to go through the maintainers =
and end
>>> > up in linux-2.6.git in time before the merge window closes. If it
>>> > weren't now allowed in during the rc-phase, it may not go into a =
stable
>>> > release either (assuming the rc/stable rules are more or less the=
 same)
>>> > and we would be looking something like five month time until the =
fix
>>> > would actually be released in a proper kernel release. Sure,
>>> > users/distros could take in some additional patches to fix issues=
 they
>>> > care about, but worst case scenarios of close to half a year to f=
ix an
>>> > issue in a kernel release does not sound quite ideal.
>>>
>>> Agreed. In the end it seems to come down to the specifics of the pa=
tch and
>>> only the maintainer can really be a good judge of whether it should=
 go in
>>> or not. Of course properly documenting each patch helps, and I beli=
eve that
>>> in itself may be good enough to address the grey areas.
>>>
>>> Here's a new patch with the fix you noted. Also added a little stub=
 about
>>> maintainers judgement, etc.
>>>
>>> From: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
>>> Subject: [PATCH] Documentation: add documentation summary for rc-se=
ries and merge window
>>>
>>> This is losely based on previous discussions on linux-kernel [1][2]=
=2E
>>> Lets also refer people reading the stable rules to
>>> Documentation/development-process/.
>>>
>>> Also add the number of days it has taken between releases,
>>> and provide the average for the last 10 releases: 86.0 days.
>>>
>>> [1] http://marc.info/?l=3Dlinux-kernel&m=3D122048427801324&w=3D2
>>> [2] http://marc.info/?l=3Dlinux-netdev&m=3D122048757705315&w=3D2
>>>
>>> Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
>>> ---
>>> =A0Documentation/development-process/2.Process | =A0 96 +++++++++++=
+++++++++++++---
>>> =A0Documentation/stable_kernel_rules.txt =A0 =A0 =A0 | =A0 =A05 ++
>>> =A02 files changed, 91 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/Documentation/development-process/2.Process b/Document=
ation/development-process/2.Process
>>> index d750321..c220646 100644
>>> --- a/Documentation/development-process/2.Process
>>> +++ b/Documentation/development-process/2.Process
>>> @@ -7,20 +7,96 @@ course of one year, the kernel has since had to e=
volve a number of
>>> =A0processes to keep development happening smoothly. =A0A solid und=
erstanding of
>>> =A0how the process works is required in order to be an effective pa=
rt of it.
>>>
>>> +2.0:SUMMARY
>>> +
>>> +This section provides a brief summary of the kernel release rules.
>>> +
>>> +2.0.0: KERNEL RELEASE RULES
>>> +
>>> +Stable kernels are released when they are ready! This means there =
are
>>> +absolutely no strict guidelines for sticking to specific dates for=
 a
>>> +kernel release.
>>> +
>>> +2.0.1: MERGE WINDOW
>>> +
>>> +The merge window opens up after the next stable kernel is released=
=2E
>>> +The merge window is when maintainers of different subsystem send p=
ull
>>> +requests to Linus for code they have been queuing up for the next
>>> +stable kernel. This is typically now done through respective
>>> +foo-next-2.6.git trees where foo is your subsystem. Each maintaine=
r
>>> +queues up patches for the next kernel cycle in this foo-next-2.6.g=
it
>>> +tree. After the merge window the kernel is worked on through the
>>> +rc-series of the kernel release. The merge window closes at the fi=
rst
>>> +rc-series release.
>>> +
>>> +After a maintainer has sent his pull request to Linus during the m=
erge
>>> +window no further new development will be accepted for that tree a=
nd
>>> +as such it marks the closure of development for that subsystem for=
 that
>>> +kernel cycle. Developers wishing to target deadlines should simply=
 work
>>> +on their development without regards or consideration for inclusio=
n to
>>> +a specific kernel release. Once development is done it should simp=
ly be
>>> +posted. If you insist on targeting a kernel release for deadlines =
you can
>>> +try to be aware of the current rc cycle development and how soon i=
t seems
>>> +the next stable kernel release will be made. When Linus notes the =
last rc
>>> +cycle released may be the last -- that is a good sign you should a=
lready
>>> +have all your development done and merged in the respective develo=
pment
>>> +tree. If your code is not ready and merged into the respective mai=
ntainers
>>> +tree prior to the announced last potential rc kernel release chanc=
es are
>>> +you missed getting your code in for the next kernel merge window.
>>> +Exemptions here are new drivers, covered below.
>>> +
>>> +2.0.2: RC-SERIES RULES
>>> +
>>> +Rules on what kind of patches are accepted after the merge window =
closes.
>>> +These are patches targeted for the kernel rc-series of a kernel pr=
ior
>>> +to its release.
>>> +
>>> + - it must fix a reported regression
>>> + - it must fix a reported security hole
>>> + - it must fix a reported oops/kernel hang
>>
>> - it must fix a bug.
>
> Well that's for certain, but there is a difference between a general
> notion of a bug and the type of bug fixes that should go in during th=
e
> rc-series. This documentation patch highlights the difference.
>
>> I do not think the 'reported' requirement is there in -rc,
>
> Well if its not reported how else would you find out about it during
> the rc-series? And if its something easily triggerable that should
> have been fixed earlier, not late in the rc-series.
>
>> and yes,
>> compile-fixes etc are welcome.
>
> Sure, but what are these doing so late in the rc-series?
>
>> Non-intrusive bugfixes too, afaict.
>
> It really depends on what you mean but generally no, and this is why =
I
> think this clarification is important.
>
> =A0Luis
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

well, this answers my question about merge window
times and, what types of patches belong where.


--=20
Justin P. Mattock
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH v2] SubmittingPatches: clarify SOB tag usage when evolving submissions
Date: Wed, 15 Aug 2012 00:52:44 -0700
Message-ID: <CAB=NE6WgKO6mTduL_6qSf0nhFaEy4LfrRi8sHGaujXdnDyi4wg@mail.gmail.com>
References: <1344548903-23117-1-git-send-email-mcgrof@do-not-panic.com>
 <5025470D.8090702@xenotime.net> <50284101.4020905@landley.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Randy Dunlap <rdunlap@xenotime.net>, torvalds@linux-foundation.org,
	tytso@mit.edu, alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rob Landley <rob@landley.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50284101.4020905@landley.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2012 at 4:49 PM, Rob Landley <rob@landley.net> wrote:
> The analogy I made was with a magazine editor, fighting off sturgeon's
> law in the slush pile, cherry-picking a few submissions to polish up and
> include in the next issue of the magazine. In this context, a
> personalized rejection letter to a new author is actually encouragement,
> and the editor's only authority is veto power with bounceback
> negotiation. "I won't accept this, but if you change it like so then
> maybe..."

Neat analogy!

>>> Developers wishing to contribute changes to the evolution
>>> of a second patch submission must supply their own Siged-off-by
>>> tag to the original authors and must submit their changes
>>> on a public mailing list or ensure that these submission
>>> are recorded somewhere publicly.
>
> Should != must.

Agreed. I believe must is good here.

>>> To date a few of these type of contributors have expressed
>>> different preferences for whether or not their own SOB tag
>>> should be used for a second code submission. Lets keep things
>>> simple and only require the contributor's SOB tag if so desired
>>> explicitly. It is not technically required if there already
>>> is a public record of their contribution somewhere.
>
> Heh. "technically required". As if there's a process separate from the
> people implementing it.

It depends on the web of trust. Its all subjective but if we want to
be safe we air on the side of caution, all in fluffy theory. In
practice obviously it does not matter -- unless someone ends up
fighting for something they really care about.

> Speaking of which, did anybody ever explicitly document the four level
> developer -> maintainer -> lieutenant -> architect thing, and how each
> level owes you a _response_?

No, and in fact I actually think our Signed-off-by language could be
strengthened if we had a bit more meaning for how valuable a
Signed-off-by tag is for each of these. Right now, its pooo.


>>> ---
>>>
>>> This v2 has Singed/Signed typo fixes.
>>>
>>>  Documentation/SubmittingPatches |   15 +++++++++++++++
>>>  1 file changed, 15 insertions(+)
>
> You realize this is a political document as much as technical, right?

No. I did not think about that actually. All I wanted to do when I
wrote this patch is end a common type of disagreement I have seen over
the years with different developers taking different positions on
whether or not their Singed-off-by should be used if they sent a small
patch to a not-yet-upstream driver. Its really quite simple so best is
to document the simplest way for us to evolve IMHO. I really do not
give a rats ass about the political nature of this. I just want us to
get work done faster and more efficiently without spending energy on
stupid questions like this one.

> Making those longer and more specific is seldom a good idea.

I agree. Whoever decides the worthiness of this will decide whether or
not this merits integration. I don't give a shit, if not merged at
least the patch is out there and we've talked about it. In this case
though I think it would help us evolve faster.

>>> diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
>>> index c379a2a..3154565 100644
>>> --- a/Documentation/SubmittingPatches
>>> +++ b/Documentation/SubmittingPatches
>>> @@ -366,6 +366,21 @@ and protect the submitter from complaints. Note that under no circumstances
>>>  can you change the author's identity (the From header), as it is the one
>>>  which appears in the changelog.
>>>
>>> +If you are submitting a large change (for example a new driver) at times
>>> +you may be asked to make quite a lot of modifications prior to getting
>>> +your change accepted. At times you may even receive patches from developers
>>> +who not only wish to tell you what you should change to get your changes
>>> +upstream but actually send you patches. If those patches were made publicly
>>> +and they do contain a Signed-off-by tag you are not expected to provide
>>
>> I would add a comma:                   tag,
>>
>> but for a patch that attempts to clarify, I don't find it very helpful.
>>
>>> +their own Signed-off-by tag on the second iteration of the patch so long
>>> +as there is a public record somewhere that can be used to show the
>>> +contributor had sent their changes with their own Signed-off-by tag.
>
> Are you expecting another SCO, or is this just the standard bueaucratic
> "once a procedure is in place we must continue to elaborate it until it
> describes approved methods of breathing"?

We should not have a document which claims a correct way kernel
developers should wipe their asses. No. But if we throw feces at each
others, perhaps a document would help explain what is fair play.

> The signed-off-by was a way of saying "I claim to be authorized to
> submit this code, so if you find out later it's plaguraized you can
> blame me". Having someone to blame makes lawyers happy, and we were
> being sued by a troll at the time.

True.

> As long as the mechanism's there, additional whatevered-by lines provide
> an easy "who do I cc if I bisect a bug to this patch and want answers".
> It also provides an email address for the original author if they
> weren't using git.

Sure, the practical stuff -- I use one tag for helping cherry pick
patches that fall under the stable - non-stable hazy area. I take them
all in backported releases while still respecting and prioritizing
upstream development.

> Getting your thingied-by: on there can also be a way of saying "I use
> this darn feature and want to see the patch go in already, sheesh" but
> the politics are actually more complicated than that. (The big questions
> Linus wants an answer to are "is doing this a good idea in the first
> place", "is this the best way to do it", and "will this thing be
> _maintained_ if an unrelated change breaks it five years from now".
> Interest from unrelated third parties doesn't necessarily answer any of
> those questions.)

I think we should not throw feces at each other for whether or not
someone added your SOB to a 2nd full patch submission if someone sent
you a SOB'd patch to you to help you evolve your first submission.
That is all.

>>> +If you receive patches privately during development you may want to
>>> +ask for these patches to be re-posted publicly or you can also decide
>>> +to merge the patches as part of a separate historical git tree that
>>> +will remain online for historical archiving.
>>
>> I don't think it's a good idea to require a historical git archive for
>> (private) patches.
>
> I think it's actively detrimental to try to require that.

Agreed.

> For a patch that was developed privately in-house at at some large
> corporation and had to go through the legal clearance dance of "Let's
> pretend that Qualcomm Innovation Center is a different entity than
> Qualcomm, and while you're at it let's pretend the Code Aurora
> Foundation is more than a partnership between Qualcomm and Qualcomm with
> Intel's name stamped on it to act as a condom over our sock puppet to
> keep the Icky GPL from affecting our patent licensing revenue"...

This is awesome :)

> And you then ask for the full development history of that patch? Not
> likely.

Um, this is not coming from anyone wearing a company hat. This is
coming from me from seeing poo being thrown around over the SOB usage.
I'm happy to ignore it if no one cares, but then next time please put
the poo down if this questions comes up again.

> Sometimes the only way the poor engineers can get serious
> external review of that sort of stuff before submitting a frozen copy to
> a legal gauntlet is to hire a consultant and have them review it under NDA.

For companies that are full of poo, yes.

> It's useful to encourage people to release early/often when they can, so
> we can critque their design before they've put a lot of effort into
> going down the wrong path (ala OpenVZ spending a dozen years getting
> containers to work right in a persistent out-of-tree fork and then
> having Linus veto the buckets-of-new-syscalls API so they had to chip
> each bit off and port it to a new API to get containers upstream). That
> winds up saving people real work in the long run.

I could not agree any more with this statement.

> But implying "submitting working code and giving us your word can be
> used under GPLv2" is not enough? Not so much.

Yup, agreed.

>> If I send a patch privately and it contains an SOB:
>> line, then the maintainer should be able to apply the patch and
>> use the SOB: from the patch (IMO).  Are you addressing some concern
>> about fraudulent emails/patches?
>>
>>> +
>>>  Special note to back-porters: It seems to be a common and useful practise
>>>  to insert an indication of the origin of a patch at the top of the commit
>>>  message (just after the subject line) to facilitate tracking. For instance,
>
> The purpose of signed-off-by is to let people figure out where code came
> from and why. If you don't do that the reviewers will ding you.

Sure.

> I'd rather communicate that than the rest of this message combined.

I've tried this before and have seen others throw poo at each other
for it. If you're fast and good -- you never have to deal with
secondary SOBs, but if you are learning -- think of small companies or
new BUs doing kernel work, then yes -- you will have poo thrown at
you, and for many things. I think the issues you pointed out are
worthy of poo throwing, the usage of the SOB tag though -- no, it
should be trivial.

  Luis

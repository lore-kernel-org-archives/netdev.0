From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH v2] SubmittingPatches: clarify SOB tag usage when evolving
 submissions
Date: Sun, 12 Aug 2012 18:49:21 -0500
Message-ID: <50284101.4020905@landley.net>
References: <1344548903-23117-1-git-send-email-mcgrof@do-not-panic.com> <5025470D.8090702@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	torvalds@linux-foundation.org, tytso@mit.edu,
	alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:65260 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775Ab2HLX4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 19:56:47 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so5990483obb.19
        for <netdev@vger.kernel.org>; Sun, 12 Aug 2012 16:56:46 -0700 (PDT)
In-Reply-To: <5025470D.8090702@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2012 12:38 PM, Randy Dunlap wrote:
> On 08/09/2012 02:48 PM, Luis R. Rodriguez wrote:
> 
>> From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
>>
>> Initial large code submissions typically are not accepted
>> on their first patch submission. The developers are
>> typically given feedback and at times some developers may
>> even submit changes to the original authors for integration
>> into their second submission attempt.

Heh. I did a talk about this at Flourish 2010 in Chicago. (There's
video, but the sound quality's so bad you'd go deaf trying to understand
what I was saying.)

The analogy I made was with a magazine editor, fighting off sturgeon's
law in the slush pile, cherry-picking a few submissions to polish up and
include in the next issue of the magazine. In this context, a
personalized rejection letter to a new author is actually encouragement,
and the editor's only authority is veto power with bounceback
negotiation. "I won't accept this, but if you change it like so then
maybe..."

>> Developers wishing to contribute changes to the evolution
>> of a second patch submission must supply their own Siged-off-by
>> tag to the original authors and must submit their changes
>> on a public mailing list or ensure that these submission
>> are recorded somewhere publicly.

Should != must.

>> To date a few of these type of contributors have expressed
>> different preferences for whether or not their own SOB tag
>> should be used for a second code submission. Lets keep things
>> simple and only require the contributor's SOB tag if so desired
>> explicitly. It is not technically required if there already
>> is a public record of their contribution somewhere.

Heh. "technically required". As if there's a process separate from the
people implementing it.

Speaking of which, did anybody ever explicitly document the four level
developer -> maintainer -> lieutenant -> architect thing, and how each
level owes you a _response_?

>> Document this on Documentation/SubmittingPatches
>>
>> Signed-off-by: Luis R. Rodriguez <mcgrof@do-not-panic.com>
> 
> 
> Note:  I'm no longer maintaining Documentation/, so I'm cc-ing Rob.

Got it.

>> ---
>>
>> This v2 has Singed/Signed typo fixes.
>>
>>  Documentation/SubmittingPatches |   15 +++++++++++++++
>>  1 file changed, 15 insertions(+)

You realize this is a political document as much as technical, right?

Making those longer and more specific is seldom a good idea.

>> diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
>> index c379a2a..3154565 100644
>> --- a/Documentation/SubmittingPatches
>> +++ b/Documentation/SubmittingPatches
>> @@ -366,6 +366,21 @@ and protect the submitter from complaints. Note that under no circumstances
>>  can you change the author's identity (the From header), as it is the one
>>  which appears in the changelog.
>>  
>> +If you are submitting a large change (for example a new driver) at times
>> +you may be asked to make quite a lot of modifications prior to getting
>> +your change accepted. At times you may even receive patches from developers
>> +who not only wish to tell you what you should change to get your changes
>> +upstream but actually send you patches. If those patches were made publicly
>> +and they do contain a Signed-off-by tag you are not expected to provide
>
> I would add a comma:                   tag,
> 
> but for a patch that attempts to clarify, I don't find it very helpful.
> 
>> +their own Signed-off-by tag on the second iteration of the patch so long
>> +as there is a public record somewhere that can be used to show the
>> +contributor had sent their changes with their own Signed-off-by tag.

Are you expecting another SCO, or is this just the standard bueaucratic
"once a procedure is in place we must continue to elaborate it until it
describes approved methods of breathing"?

The signed-off-by was a way of saying "I claim to be authorized to
submit this code, so if you find out later it's plaguraized you can
blame me". Having someone to blame makes lawyers happy, and we were
being sued by a troll at the time.

As long as the mechanism's there, additional whatevered-by lines provide
an easy "who do I cc if I bisect a bug to this patch and want answers".
It also provides an email address for the original author if they
weren't using git.

Getting your thingied-by: on there can also be a way of saying "I use
this darn feature and want to see the patch go in already, sheesh" but
the politics are actually more complicated than that. (The big questions
Linus wants an answer to are "is doing this a good idea in the first
place", "is this the best way to do it", and "will this thing be
_maintained_ if an unrelated change breaks it five years from now".
Interest from unrelated third parties doesn't necessarily answer any of
those questions.)

>> +If you receive patches privately during development you may want to
>> +ask for these patches to be re-posted publicly or you can also decide
>> +to merge the patches as part of a separate historical git tree that
>> +will remain online for historical archiving.
> 
> I don't think it's a good idea to require a historical git archive for
> (private) patches.

I think it's actively detrimental to try to require that.

For a patch that was developed privately in-house at at some large
corporation and had to go through the legal clearance dance of "Let's
pretend that Qualcomm Innovation Center is a different entity than
Qualcomm, and while you're at it let's pretend the Code Aurora
Foundation is more than a partnership between Qualcomm and Qualcomm with
Intel's name stamped on it to act as a condom over our sock puppet to
keep the Icky GPL from affecting our patent licensing revenue"...

And you then ask for the full development history of that patch? Not
likely. Sometimes the only way the poor engineers can get serious
external review of that sort of stuff before submitting a frozen copy to
a legal gauntlet is to hire a consultant and have them review it under NDA.

It's useful to encourage people to release early/often when they can, so
we can critque their design before they've put a lot of effort into
going down the wrong path (ala OpenVZ spending a dozen years getting
containers to work right in a persistent out-of-tree fork and then
having Linus veto the buckets-of-new-syscalls API so they had to chip
each bit off and port it to a new API to get containers upstream). That
winds up saving people real work in the long run.

But implying "submitting working code and giving us your word can be
used under GPLv2" is not enough? Not so much.

> If I send a patch privately and it contains an SOB:
> line, then the maintainer should be able to apply the patch and
> use the SOB: from the patch (IMO).  Are you addressing some concern
> about fraudulent emails/patches?
> 
>> +
>>  Special note to back-porters: It seems to be a common and useful practise
>>  to insert an indication of the origin of a patch at the top of the commit
>>  message (just after the subject line) to facilitate tracking. For instance,

The purpose of signed-off-by is to let people figure out where code came
from and why. If you don't do that the reviewers will ding you.

I'd rather communicate that than the rest of this message combined.

Rob
-- 
GNU/Linux isn't: Linux=GPLv2, GNU=GPLv3+, they can't share code.
Either it's "mere aggregation", or a license violation.  Pick one.

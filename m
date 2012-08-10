From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH v2] SubmittingPatches: clarify SOB tag usage when evolving
 submissions
Date: Fri, 10 Aug 2012 10:38:21 -0700
Message-ID: <5025470D.8090702@xenotime.net>
References: <1344548903-23117-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, tytso@mit.edu,
	alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rob Landley <rob@landley.net>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344548903-23117-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/09/2012 02:48 PM, Luis R. Rodriguez wrote:

> From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
> 
> Initial large code submissions typically are not accepted
> on their first patch submission. The developers are
> typically given feedback and at times some developers may
> even submit changes to the original authors for integration
> into their second submission attempt.
> 
> Developers wishing to contribute changes to the evolution
> of a second patch submission must supply their own Siged-off-by
> tag to the original authors and must submit their changes
> on a public mailing list or ensure that these submission
> are recorded somewhere publicly.
> 
> To date a few of these type of contributors have expressed
> different preferences for whether or not their own SOB tag
> should be used for a second code submission. Lets keep things
> simple and only require the contributor's SOB tag if so desired
> explicitly. It is not technically required if there already
> is a public record of their contribution somewhere.
> 
> Document this on Documentation/SubmittingPatches
> 
> Signed-off-by: Luis R. Rodriguez <mcgrof@do-not-panic.com>


Note:  I'm no longer maintaining Documentation/, so I'm cc-ing Rob.

> ---
> 
> This v2 has Singed/Signed typo fixes.
> 
>  Documentation/SubmittingPatches |   15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
> index c379a2a..3154565 100644
> --- a/Documentation/SubmittingPatches
> +++ b/Documentation/SubmittingPatches
> @@ -366,6 +366,21 @@ and protect the submitter from complaints. Note that under no circumstances
>  can you change the author's identity (the From header), as it is the one
>  which appears in the changelog.
>  
> +If you are submitting a large change (for example a new driver) at times
> +you may be asked to make quite a lot of modifications prior to getting
> +your change accepted. At times you may even receive patches from developers
> +who not only wish to tell you what you should change to get your changes
> +upstream but actually send you patches. If those patches were made publicly
> +and they do contain a Signed-off-by tag you are not expected to provide


I would add a comma:                   tag,

but for a patch that attempts to clarify, I don't find it very helpful.

> +their own Signed-off-by tag on the second iteration of the patch so long
> +as there is a public record somewhere that can be used to show the
> +contributor had sent their changes with their own Signed-off-by tag.

> +

> +If you receive patches privately during development you may want to
> +ask for these patches to be re-posted publicly or you can also decide
> +to merge the patches as part of a separate historical git tree that
> +will remain online for historical archiving.


I don't think it's a good idea to require a historical git archive for
(private) patches.  If I send a patch privately and it contains an SOB:
line, then the maintainer should be able to apply the patch and
use the SOB: from the patch (IMO).  Are you addressing some concern
about fraudulent emails/patches?

> +
>  Special note to back-porters: It seems to be a common and useful practise
>  to insert an indication of the origin of a patch at the top of the commit
>  message (just after the subject line) to facilitate tracking. For instance,



-- 
~Randy

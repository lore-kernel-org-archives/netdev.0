From: Ryan Mallon <rmallon@gmail.com>
Subject: Re: [PATCH] SubmittingPatches: clarify SOB tag usage when evolving
 submissions
Date: Fri, 10 Aug 2012 12:57:29 +1000
Message-ID: <50247899.7040906@gmail.com>
References: <1344545493-6820-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, rdunlap@xenotime.net, tytso@mit.edu,
	alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344545493-6820-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/08/12 06:51, Luis R. Rodriguez wrote:
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
> ---
>  Documentation/SubmittingPatches |   15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
> index c379a2a..e018043 100644
> --- a/Documentation/SubmittingPatches
> +++ b/Documentation/SubmittingPatches
> @@ -366,6 +366,21 @@ and protect the submitter from complaints. Note that under no circumstances
>  can you change the author's identity (the From header), as it is the one
>  which appears in the changelog.
>  
> +If you are submitting a large change (for example a new driver) at times
> +you may be asked to make quite a lot of modifications prior to getting
> +your change accepted. 

This applies to any patch, not just large ones and/or drivers.

> At times you may even receive patches from developers
> +who not only wish to tell you what you should change to get your changes
> +upstream but actually send you patches. 

This sentence is long and confusing. Perhaps something like: "Other
developers may send patches to show what changes should be made, rather
than just making comments".

> If those patches were made publicly
> +and they do contain a Singed-off-by tag you are not expected to provide
> +their own Singed-off-by tag on the second iteration of the patch so long
> +as there is a public record somewhere that can be used to show the
> +contributor had sent their changes with their own Singed-off-by tag.

If another developer sends a patch with a Signed-off-by, regardless of
whether it is a patch against mainline, or a patch on top of a patch,
why would you not be required to keep the Signed-off-by tag? Does this
mean that I can review somebodies else's patch, send them a patch on top
of it with my Signed-off-by, and they can simply drop it and take my
work uncredited?

If a developer wants to provided patches on top of someone else's work,
but does not want to be credited with a Signed-off-by, then surely they
should just not sign-off their patch?

You also misspelled "Signed-of-by" several times.

> +
> +If you receive patches privately during development you may want to
> +ask for these patches to be re-posted publicly or you can also decide
> +to merge the patches as part of a separate historical git tree that
> +will remain online for historical archiving.

I don't think this necessarily needs to be stated. Lots of patches,
especially drivers, have probably had several authors, but only require
the sign-off of the person doing the actual submission. So the rules
should be (IMHO):

 1) The person submitting the code must sign the patch off.
 2) If another person contributes to the code, whether during
    development, or as part of a review, then they should have
    a Signed-off-by tag applied only if they provide one.
 3) Signed-off-by tags (all tags really) should never be added
    without the express permission of the person themselves.

If additional credit needs to be given, but the creditor doesn't want to
provide a Signed-off-by then one of the other tags could be used (such
as Reviewed-by), or the person could be mentioned in the changelog
perhaps? e.g:

  "Parts of the foo function provided by Joe Bloggs <joe@bloggs.com>"

~Ryan

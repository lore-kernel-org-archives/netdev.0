From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH 0/5] 2.4.27-pre3 pcnet32.c
Date: Wed, 26 May 2004 15:15:23 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405262215.i4QMFOO28045@DYN318364BLD.beaverton.ibm.com>
References: <40AE7049.80900@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com (Jeff Garzik)
In-Reply-To: <40AE7049.80900@pobox.com> from "Jeff Garzik" at May 21, 2004 05:10:33 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

Three more questions.

1) Should there be a patch number when the number of patches is not known
in advance, or should it be omitted?
 [PATCH 1 2.4.27] pcnet32: whatever
 [PATCH 2 2.4.27] pcnet32: something else

2) If a group of patches is submitted and then more bugs are discovered
which should be fixed, what should I do?
 [PATCH 5/5 2.4.27] pcnet32: ...
 [PATCH 6 2.4.27] pcnet32: a couple days later

3) If an error is discovered in a patch and the patch itself should be
fixed, how would you like that indicated?
 [PATCH 8/5 2.4.27] pcnet32: submitted
 [PATCH 8/5 2.4.27] pcnet32: oops, this should be different.

> 
> Don Fry wrote:
> Status: O
> 
> > Please apply the following patches to 2.4.27-pre3.  The first four are simple
> > "one line" fixes. The last removes the timer I added a little while ago,
> > as it added complexity without improving performance.
> > 
> > [PATCH 1/5] 2.4.27-pre3 pcnet32 add static to two routines.
> > [PATCH 2/5] 2.4.27-pre3 pcnet32 avoid hard hang with some chip variants.
> > [PATCH 3/5] 2.4.27-pre3 pcnet32 correct 79C976 variant string.
> > [PATCH 4/5] 2.4.27-pre3 pcnet32 fix boundary comparison bug.
> > [PATCH 5/5] 2.4.27-pre3 pcnet32 remove timer and complexity.
> 
> 
> It would help me a lot if you changed your email subject line in two 
> minor ways:
> 
> 1) Include the kernel version _inside_ the brackets,
> 
> 	[PATCH 1/5 2.4.27-pre3]
> 
> 2) Just to make it look a tad nicer and more consistent with other 
> changelog entries, add a colon after the driver name:
> 
> 	[PATCH 1/5 2.6.6] pcnet32: mark two routines static
> 
> This allows me to pass your submission fully automated through scripts. 
>   The resultant one-line description of your patch becomes
> 
> 	[PATCH] pcnet32: mark two routines static
> 
> when my scripts merge your patch into the BK repository.
> 
-- 
Don Fry
brazilnut@us.ibm.com

From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/5] 2.4.27-pre3 pcnet32.c
Date: Fri, 21 May 2004 17:10:33 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40AE7049.80900@pobox.com>
References: <200405212055.i4LKtx110244@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, netdev@oss.sgi.com,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264780AbUEUVKs@vger.kernel.org>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <200405212055.i4LKtx110244@DYN318364BLD.beaverton.ibm.com>
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> Please apply the following patches to 2.4.27-pre3.  The first four are simple
> "one line" fixes. The last removes the timer I added a little while ago,
> as it added complexity without improving performance.
> 
> [PATCH 1/5] 2.4.27-pre3 pcnet32 add static to two routines.
> [PATCH 2/5] 2.4.27-pre3 pcnet32 avoid hard hang with some chip variants.
> [PATCH 3/5] 2.4.27-pre3 pcnet32 correct 79C976 variant string.
> [PATCH 4/5] 2.4.27-pre3 pcnet32 fix boundary comparison bug.
> [PATCH 5/5] 2.4.27-pre3 pcnet32 remove timer and complexity.


It would help me a lot if you changed your email subject line in two 
minor ways:

1) Include the kernel version _inside_ the brackets,

	[PATCH 1/5 2.4.27-pre3]

2) Just to make it look a tad nicer and more consistent with other 
changelog entries, add a colon after the driver name:

	[PATCH 1/5 2.6.6] pcnet32: mark two routines static

This allows me to pass your submission fully automated through scripts. 
  The resultant one-line description of your patch becomes

	[PATCH] pcnet32: mark two routines static

when my scripts merge your patch into the BK repository.

BTW, you don't need to resend your 2.4 and 2.6 pcnet32 patches, this is 
just for future reference.

	Jeff


P.S.  Somebody should put this into Documentation/SubmittingPatches...

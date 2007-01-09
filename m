From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] s390: qeth driver fixes
Date: Tue, 09 Jan 2007 02:23:23 -0500
Message-ID: <45A342EB.2020200@pobox.com>
References: <20070108162934.GA21639@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60503 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128AbXAIHX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 02:23:29 -0500
To: Frank Pavlic <fpavlic@de.ibm.com>
In-Reply-To: <20070108162934.GA21639@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Pavlic wrote:
> Hi ,
> 
> please apply following 5 patches for s390 network device drivers.
> Sorry for the fifth patch containing some lines which just remove
> whitespaces. Another patch will follow in the next couple of days
> with more whitespace and coding style cleanups in drivers/s390/net.
> 
> Thank you 
> 
> Frank
> 
> [PATCH 1/5] s390: qeth driver fixes
> 
> From: Frank Blaschka <Frank.Blaschka@de.ibm.com>
> From: Ursula Braun <braunu@de.ibm.com>
>         - VLAN header reordering did not work on packets
>           received through qeth interface in layer 2 mode.
>           This caused dhcpcd not to work with VLAN devices.
> 	- set qeth performance statistics initally inactive
> 
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

applied patches 1-4 of 5.  patch #5 failed to apply, and also, it's not 
really appropriate for the current release candidate bugfix window.

Also:

1) Please include notes to me and reviewers following the "---" marker. 
  Everything before the "---" is copied /verbatim/ into the kernel 
changelog.  Everything after "---", except the patch itself, is ignored.

I had to hand-edit each of your patches, to remove the "Hi , ... Frank" 
paragraph and the "[PATCH 1/5] S390: ..." from the body of each email.

2) Your subject line should be more descriptive.  The subject line is 
used to generate a one-line summary.  You can see how your subject lines 
are vague:

	[PATCH] s390: qeth driver fixes
	[PATCH] s390: qeth driver fixes
	[PATCH] s390: qeth driver fixes

Here, I had to hand-edit each email subject line to be more descriptive.

3) In general, review Documentation/SubmittingPatches and 
http://linux.yyz.us/patch-format.html

	Jeff



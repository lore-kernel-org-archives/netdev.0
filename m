From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: Re: [PATCH 1/5] s390: qeth driver fixes
Date: Tue, 9 Jan 2007 14:39:22 +0100
Message-ID: <20070109133922.GA21804@de.ibm.com>
References: <20070108162934.GA21639@de.ibm.com> <45A342EB.2020200@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:46796 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077AbXAINiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 08:38:55 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l09Dblbc000738
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 08:37:47 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l09Dcsd2451488
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 06:38:54 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l09DcsJw008800
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 06:38:54 -0700
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <45A342EB.2020200@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the trouble and also thank you very much
for having done the extra work. I made the patches
using git-format-patch so seems that I have to review
them more carefully or I still haven't understand to use
git-format-patch properly. 
In any case I will read the documents you mentioned 
once again to keep such points in mind...


Frank

On Tue, Jan 09, 2007 at 02:23:23AM -0500, Jeff Garzik wrote:
> Frank Pavlic wrote:
> >Hi ,
> >
> >please apply following 5 patches for s390 network device drivers.
> >Sorry for the fifth patch containing some lines which just remove
> >whitespaces. Another patch will follow in the next couple of days
> >with more whitespace and coding style cleanups in drivers/s390/net.
> >
> >Thank you
> >
> >Frank
> >
> >[PATCH 1/5] s390: qeth driver fixes
> >
> >From: Frank Blaschka <Frank.Blaschka@de.ibm.com>
> >From: Ursula Braun <braunu@de.ibm.com>
> >        - VLAN header reordering did not work on packets
> >          received through qeth interface in layer 2 mode.
> >          This caused dhcpcd not to work with VLAN devices.
> >	- set qeth performance statistics initally inactive
> >
> >Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
> 
> applied patches 1-4 of 5.  patch #5 failed to apply, and also, it's not
> really appropriate for the current release candidate bugfix window.
> 
> Also:
> 
> 1) Please include notes to me and reviewers following the "---" marker.
>  Everything before the "---" is copied /verbatim/ into the kernel
> changelog.  Everything after "---", except the patch itself, is ignored.
> 
> I had to hand-edit each of your patches, to remove the "Hi , ... Frank"
> paragraph and the "[PATCH 1/5] S390: ..." from the body of each email.
> 
> 2) Your subject line should be more descriptive.  The subject line is
> used to generate a one-line summary.  You can see how your subject lines
> are vague:
> 
> 	[PATCH] s390: qeth driver fixes
> 	[PATCH] s390: qeth driver fixes
> 	[PATCH] s390: qeth driver fixes
> 
> Here, I had to hand-edit each email subject line to be more descriptive.
> 
> 3) In general, review Documentation/SubmittingPatches and
> http://linux.yyz.us/patch-format.html
> 
> 	Jeff
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

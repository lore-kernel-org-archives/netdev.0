From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v6] sctp: be more restrictive in transport selection on
 bundled sacks
Date: Mon, 2 Jul 2012 08:25:31 -0400
Message-ID: <20120702122531.GA29681@hmsreliant.think-freely.org>
References: <1341061466-4186-1-git-send-email-nhorman@tuxdriver.com>
 <20120630.173945.173993639982489712.davem@davemloft.net>
 <20120701124750.GA19498@neilslaptop.think-freely.org>
 <20120701.144319.1120248166079750922.davem@davemloft.net>
 <20120701234424.GA23935@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50654 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab2GBMZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 08:25:46 -0400
Content-Disposition: inline
In-Reply-To: <20120701234424.GA23935@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 01, 2012 at 07:44:25PM -0400, Neil Horman wrote:
> On Sun, Jul 01, 2012 at 02:43:19PM -0700, David Miller wrote:
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Sun, 1 Jul 2012 08:47:50 -0400
> > 
> > > Perhaps we could modify the SubmittingPatches document to indicate that an
> > > Acked-by from a subsystem maintainer implicitly confers authority on the
> > > upstream receiver to request reasonable stylistic changes that don't affect the
> > > functionality of the patch in the interests of maintaining coding conventions.
> > 
> > Yes, that would make sense.
> > 
> 
> 
> I'll propose it in a few days.
> Neil
> 
How does this language sound to you?


diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
index c379a2a..1eaaeb1 100644
--- a/Documentation/SubmittingPatches
+++ b/Documentation/SubmittingPatches
@@ -414,6 +414,16 @@ the part which affects that maintainer's code.  Judgement should be used here.
 When in doubt people should refer to the original discussion in the mailing
 list archives.
 
+Note that an Acked-by: From a subsystem maintainer on a given patch confers
+upon the tree maintainer integrating the path the authority to carry those Acks
+forward through subsequent versions of a patch, as long as those versions do not
+significantly impact the functionality of the patch.  For example, say the isdn
+subsystem maintainer sends an Acked-by: on version 1 of a patch bound for the
+networking tree.  The networking maintainer then requests that some comments in
+the code be modified to comply with the CodingStyle document.  The networking
+tree maintanier may reapply the subsystem maintainers Acked-by: to the new
+version as no significant changes were made to the patch functionality.
+
 If a person has had the opportunity to comment on a patch, but has not
 provided such comments, you may optionally add a "Cc:" tag to the patch.
 This is the only tag which might be added without an explicit action by the

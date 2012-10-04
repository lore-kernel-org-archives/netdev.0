From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Thu, 4 Oct 2012 20:13:49 +0200
Message-ID: <CA+MoWDoOKF1NHmDbaGwpRCpHLpnHfjHngR2HrV-tWLj+8pFV7g@mail.gmail.com>
References: <1349281090-10013-20-git-send-email-peter.senna@gmail.com>
	<20121003092508.6a7da662@nehalam.linuxnetplumber.net>
	<CA+MoWDp4W5BCA1t_HgEtLhMs1btVTOkbtBytOVtAzJriEZ-16A@mail.gmail.com>
	<20121004074442.180d8f01@nehalam.linuxnetplumber.net>
	<CA+MoWDp=_F9opJbVkv9sDsmoykm7MTUZwRVumKCB0ZqDwD6NoQ@mail.gmail.com>
	<20121004104045.4fa02775@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: mlindner@marvell.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39475 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480Ab2JDSNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 14:13:51 -0400
In-Reply-To: <20121004104045.4fa02775@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

Thanks for the patience.

> The purpose of the commit message is not only so other developers understand
> the patch. It is also so that the consumers (distro's and maintainers)
> understand the scope of the impact.  It maybe that your effort uncovers

I was not considering the scope of the impact. I'm fixing bugs found
by Coccinelle meaning that my bug hunting is based on static program
analysis. My evaluation of what to do is simpler: Can my change make
the code better? If I believe that yes, I make the patch.

> a really bad security hole that requires a CVE and a re-release of a
> major enterprise product like RHEL, or it could just be a minor corner
> case that can never realistically happen. Unless you give a more complete
> description, someone else will have to do it for each case.

This is a mix between what I do not want and what I can't do. I can't
give that complete description for consumers and distro maintainers
for drivers that I do not know completely. I do not know how critical
those bugs are in real life. I was expecting that the maintainer, who
knows the drivers details, would do that sort of things when needed.

Isn't enough fixing bugs and describing it correctly in a technical perspective?

Thanks,

Peter
-- 
Peter

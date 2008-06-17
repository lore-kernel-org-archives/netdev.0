From: John Rigby <jrigby@freescale.com>
Subject: Re: [PATCH] [Rev2] MPC5121 FEC support
Date: Tue, 17 Jun 2008 13:43:40 -0600
Message-ID: <485813EC.6030602@freescale.com>
References: <1213729717-26688-1-git-send-email-jrigby@freescale.com> <20080617192237.GA12961@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, netdev@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:63894 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbYFQTn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 15:43:59 -0400
In-Reply-To: <20080617192237.GA12961@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Sam,  Scott already addressed most of your issues.  The 
background that you are likely missing and I will add to the patch 
header is that the 5121 has an FEC core with all the same registers as 
8xx except the order of the registers is scrambled.  Fortunately the old 
FEC only exists on CPM1 machines so we can use CONFIG_CPM1 to 
differentiate between the two.


>
> I we have a conversion from fec_t to struct fec
> then this is a separate patch in the normal case.
>   
I'll split the patch into a clean-up patch followed by a 5121 patch.


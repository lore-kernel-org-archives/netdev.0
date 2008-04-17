From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v2][POWERPC] qe_lib and ucc_geth: switch to the cpm_muram implementation
Date: Thu, 17 Apr 2008 09:10:44 -0500
Message-ID: <20080417141043.GA21793@ld0162-tx32.am.freescale.net>
References: <20080416182214.GA20056@polina.dev.rtsoft.ru> <989B956029373F45A0B8AF02970818900200750D@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: avorontsov@ru.mvista.com, Kumar Gala <galak@kernel.crashing.org>,
	linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	Tabi Timur <timur@freescale.com>, netdev@vger.kernel.org
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:51207 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755384AbYDQOKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 10:10:52 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m3HEAjZ5029059
	for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 07:10:45 -0700 (MST)
Received: from ld0162-tx32.am.freescale.net (ld0162-tx32.am.freescale.net [10.82.19.112])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m3HEAiYP006973
	for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 09:10:45 -0500 (CDT)
Content-Disposition: inline
In-Reply-To: <989B956029373F45A0B8AF02970818900200750D@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2008 at 08:38:19PM -0700, Li Yang wrote:
> It is a good thing to unify the CPM dpram operation and QE muram
> operation.  But I'm having concerns about the naming as CPM is an
> obsolete block.  Can we change to use the new name QE instead?

And then change it again when marketing decides that CPM4 will be called
something other than QE2? :-P

-Scott

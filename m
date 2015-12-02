From: Liberman Igal <Igal.Liberman@freescale.com>
Subject: RE: [v8, 2/6] fsl/fman: Add FMan support
Date: Wed, 2 Dec 2015 07:05:09 +0000
Message-ID: <DM2PR03MB509F4530CBE707667F711D2E60E0@DM2PR03MB509.namprd03.prod.outlook.com>
References: <1448886062-16962-1-git-send-email-igal.liberman@freescale.com>
	<1448886062-16962-3-git-send-email-igal.liberman@freescale.com>
 <20151201.162810.1750455760429212300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0140.outbound.protection.outlook.com ([157.56.111.140]:48492
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755974AbbLBHFM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 02:05:12 -0500
In-Reply-To: <20151201.162810.1750455760429212300.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
Thank you for your feedback, I'll address it and re-submit.

Regards,
Igal Liberman

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, December 01, 2015 11:28 PM
> To: Liberman Igal-B31950 <Igal.Liberman@freescale.com>
> Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; linux-
> kernel@vger.kernel.org; Wood Scott-B07421 <scottwood@freescale.com>;
> Bucur Madalin-Cristian-B32716 <madalin.bucur@freescale.com>;
> pebolle@tiscali.nl; joakim.tjernlund@transmode.se; ppc@mindchasers.com;
> stephen@networkplumber.org
> Subject: Re: [v8, 2/6] fsl/fman: Add FMan support
> 
> From: <igal.liberman@freescale.com>
> Date: Mon, 30 Nov 2015 14:20:58 +0200
> 
> > +typedef irqreturn_t (fman_exceptions_cb)(struct fman *fman,
> > +					 enum fman_exceptions exception);
> 
> Function and function pointer declarations and definitions should be
> indented such that the second and subsequent lines begin precisely at the
> first column after the openning parenthesis of the first line.
> 
> Please audit this and fix it in your entire submission, almost ever new such
> case is done incorrectly.
> 
> > +	fman->state->exceptions = (EX_DMA_BUS_ERROR                 |
> > +					EX_DMA_READ_ECC              |
> > +					EX_DMA_SYSTEM_WRITE_ECC      |
> > +					EX_DMA_FM_WRITE_ECC          |
> > +					EX_FPM_STALL_ON_TASKS        |
> > +					EX_FPM_SINGLE_ECC            |
> > +					EX_FPM_DOUBLE_ECC            |
> > +
> 	EX_QMI_DEQ_FROM_UNKNOWN_PORTID |
> > +					EX_BMI_LIST_RAM_ECC          |
> > +					EX_BMI_STORAGE_PROFILE_ECC   |
> > +					EX_BMI_STATISTICS_RAM_ECC    |
> > +					EX_MURAM_ECC                 |
> > +					EX_BMI_DISPATCH_RAM_ECC      |
> > +					EX_QMI_DOUBLE_ECC            |
> > +					EX_QMI_SINGLE_ECC);
> 
> The same applies to multi-line parenthesized expressions like this one.
> Again, please audit and fix this in your entire submission.
> 
> Thanks.

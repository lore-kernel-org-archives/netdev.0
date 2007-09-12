From: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Subject: RE: [PATCH v3] Make the pr_*() family of macros in kernel.h complete
Date: Wed, 12 Sep 2007 11:44:56 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E27014F9FDA@az33exm24.fsl.freescale.net>
References: <11896151802410-git-send-email-Emilian.Medve@Freescale.com> <Pine.LNX.4.64.0709122003410.22467@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<i2c@lm-sensors.org>, <linux-omap-open-source@linux.omap.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:39384 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766AbXILSpD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 14:45:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.64.0709122003410.22467@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Jan Engelhardt [mailto:jengelh@computergmbh.de] 
> Sent: Wednesday, September 12, 2007 1:04 PM
> To: Medve Emilian-EMMEDVE1
> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org; 
> i2c@lm-sensors.org; linux-omap-open-source@linux.omap.com
> Subject: Re: [PATCH v3] Make the pr_*() family of macros in 
> kernel.h complete
> 
> 
> On Sep 12 2007 11:39, Emil Medve wrote:
> >
> >Other/Some pr_*() macros are already defined in kernel.h, 
> but pr_err() was defined
> >multiple times in several other places
> 
> Note http://lkml.org/lkml/2007/8/4/30 .


Hi Jan,


I didn't see that thread before I submitted the patch... I don't want to
start the conversation from the top 'cause this is not a patch that
fixes some existing showstopper... however, I have two comments to make.
First, this patch doesn't have the trailing "\n" problem that one had.
Second, it seems that multiple people at different moments in time have
the same idea to complete and, more important, to use the pr_*() family
of macros because I guess it makes it easier to use them. In addition,
it would make it less likely for people to forget using the loglevel in
their kernel messages.

Is trying to add them a dead path? Thing is that the existing ones
suggest to, more or less, new people to the kernel that they should use
them and then discover the incompleteness/inconsistency...


Cheers,
Emil.

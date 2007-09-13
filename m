From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH v3] Make the pr_*() family of macros in kernel.h
	complete
Date: Wed, 12 Sep 2007 22:11:14 -0700
Message-ID: <1189660274.19708.125.camel@localhost>
References: <11896151802410-git-send-email-Emilian.Medve@Freescale.com>
	 <Pine.LNX.4.64.0709122003410.22467@fbirervta.pbzchgretzou.qr>
	 <598D5675D34BE349929AF5EDE9B03E27014F9FDA@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	i2c@lm-sensors.org, linux-omap-open-source@linux.omap.com
To: Medve Emilian-EMMEDVE1 <Emilian.Medve@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1454 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914AbXIMFL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 01:11:27 -0400
In-Reply-To: <598D5675D34BE349929AF5EDE9B03E27014F9FDA@az33exm24.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-12 at 11:44 -0700, Medve Emilian-EMMEDVE1 wrote:
> First, this patch doesn't have the trailing "\n" problem that one had.

I expect all the kernel logging functions to be
overhauled eventually.

I'd prefer a mechanism that somehow supports
identifying complete messages.  I think the new
pr_<level> functions are not particularly useful
without a mechanism to avoid or identify multiple
processors or threads interleaving partial in-progress
multiple statement messages.

I've got a very large patch series that converts _all_
the current single line messages that use KERN_<level>
to pr_<level> and identifies, prefixes and postfixes
the rest of the multiple source line messages.

At some point, sooner or later, the logging functions
will be improved.  Apparently, more likely later.

cheers, Joe


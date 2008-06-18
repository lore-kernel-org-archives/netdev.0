From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 1/2] fs_enet: fix checkpatch.pl problems
Date: Wed, 18 Jun 2008 10:50:36 -0500
Message-ID: <20080618155036.GB3887@loki.buserror.net>
References: <1213743794-3537-1-git-send-email-jrigby@freescale.com> <1213743794-3537-2-git-send-email-jrigby@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, jeff@garzik.org,
	Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org
To: John Rigby <jrigby@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:62470 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbYFRPuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 11:50:54 -0400
Content-Disposition: inline
In-Reply-To: <1213743794-3537-2-git-send-email-jrigby@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 05:03:13PM -0600, John Rigby wrote:
>  static int __devinit find_phy(struct device_node *np,
> -                              struct fs_platform_info *fpi)
> +			      struct fs_platform_info *fpi)

Please don't make this sort of change.  Spaces were used deliberately,
because it's alignment rather than indentation, and using tabs would make
things be unaligned with tab sizes other than 8, and (as can be seen above)
in patches.

Unfortunately, it's non-trivial to make checkpatch tell the difference
between the two (it would need to parse the language rather than do a simple
regex).

-Scott

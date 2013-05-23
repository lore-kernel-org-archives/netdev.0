From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: smsc911x: don't artificially limit build
Date: Wed, 22 May 2013 23:58:55 -0700 (PDT)
Message-ID: <20130522.235855.205103899466949885.davem@davemloft.net>
References: <1369131757-9335-1-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: mark.rutland@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab3EWG64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 02:58:56 -0400
In-Reply-To: <1369131757-9335-1-git-send-email-mark.rutland@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rutland <mark.rutland@arm.com>
Date: Tue, 21 May 2013 11:22:37 +0100

> Currently the SMSC911X driver may only be built for a specific set of
> architectures, being limited to do so by a Kconfig depends line. This
> means that if a platform wishes to use the driver, its architecture must
> be added to the list explicitly, introducing pointless churn.
> 
> This may have been due to the driver's use of the {read,write}s{b,w,l}
> functions, which have since been replaced with the more standard
> io{read,write}{8,16,32}_rep. We can instead depend on HAS_IOMEM, which
> should prevent build issues while allowing the driver to be built for
> currently unlisted architectures, including x86 and arm64.
> 
> This patch removes the explicit list of architectures from the driver's
> depend line, and replaces it with a dependency on HAS_IOMEM.
> 
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>

Applied.

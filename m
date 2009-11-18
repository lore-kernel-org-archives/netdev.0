From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 0/3] TI EMAC driver : Make driver re-usable on non-davinci platforms.
Date: Wed, 18 Nov 2009 09:53:47 -0800
Message-ID: <87r5rvd8ic.fsf@deeprootsystems.com>
References: <1258537328-31527-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Sriramakrishnan <srk@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:34448 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758064AbZKRRxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 12:53:48 -0500
Received: by bwz27 with SMTP id 27so1397722bwz.21
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2009 09:53:54 -0800 (PST)
In-Reply-To: <1258537328-31527-1-git-send-email-srk@ti.com> (Sriramakrishnan's message of "Wed\, 18 Nov 2009 15\:12\:05 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sriramakrishnan <srk@ti.com> writes:

> The Davinci EMAC peripheral is also available on other TI platforms -
> notably TI AM3517 SoC. The following series of patches modify the driver 
> suitably to make it platform agnostic.
>
> Sriramakrishnan (3):
>   TI Davinci EMAC : Re-use driver for other platforms.
>   TI Davinci EMAC : add platform specific interrupt enable/disable
>     logic.
>   TI Davinci EMAC : Abstract Buffer address translation logic.
>

As David proposed, this should go upstream via the ARM/DaVinci route.

Can you please re-submit against current DaVinci git?  This series
doesn't apply there currently.

Kevin

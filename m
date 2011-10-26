From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/2 v2] net/smsc911x: Add regulator support
Date: Wed, 26 Oct 2011 14:36:07 +0100
Message-ID: <20111026133607.GB2325@opensource.wolfsonmicro.com>
References: <1319627104-7779-1-git-send-email-linus.walleij@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Linus Walleij <linus.walleij@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:33658 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932742Ab1JZNgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 09:36:09 -0400
Content-Disposition: inline
In-Reply-To: <1319627104-7779-1-git-send-email-linus.walleij@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2011 at 01:05:04PM +0200, Linus Walleij wrote:
> From: Robert Marklund <robert.marklund@stericsson.com>
> 
> Add some basic regulator support for the power pins, as needed
> by the ST-Ericsson Snowball platform that powers up the SMSC911
> chip using an external regulator.

Reviewed-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

but it does look like the code could be simplified with the
regulator_bulk API - it'd mean you wouldn't need to do per regulator
API calls and would do all your unwinding if the second operation fails.

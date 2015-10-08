From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] regmap: Allow installing custom
 reg_update_bits function
Date: Thu, 08 Oct 2015 04:01:54 -0700 (PDT)
Message-ID: <20151008.040154.1768656821314361005.davem@davemloft.net>
References: <1443717488-16533-1-git-send-email-jon@ringle.org>
	<20151006163011.GU12635@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jringle@gridpoint.com
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbbJHKqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 06:46:11 -0400
In-Reply-To: <20151006163011.GU12635@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Tue, 6 Oct 2015 17:30:11 +0100

> On Thu, Oct 01, 2015 at 12:38:07PM -0400, jon@ringle.org wrote:
>> From: Jon Ringle <jringle@gridpoint.com>
>> 
>> This commit allows installing a custom reg_update_bits function for cases where
>> the hardware provides a mechanism to set or clear register bits without a
>> read/modify/write cycle. Such is the case with the Microchip ENCX24J600.
> 
> Thanks, I've applied this.  I'll extend it so that individual devices
> can do this as well - I've not looked at your driver but it might be
> that this is a better option than regmap_bus for your driver (but both
> are supported so meh).  Dave, I've tagged the commit and there's a pull
> request for this below:
> 
> The following changes since commit 6ff33f3902c3b1c5d0db6b1e2c70b6d76fba357f:
> 
>   Linux 4.3-rc1 (2015-09-12 16:35:56 -0700)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/broonie/regmap.git tags/regmap-offload-update-bits

I've pulled this into my 'net-next' tree, thanks.

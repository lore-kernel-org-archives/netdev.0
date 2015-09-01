From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix temperature reporting
Date: Tue, 01 Sep 2015 15:04:15 -0700 (PDT)
Message-ID: <20150901.150415.835700106114532616.davem@davemloft.net>
References: <20150901180741.1451e146@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prashant@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbbIAWEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 18:04:16 -0400
In-Reply-To: <20150901180741.1451e146@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Tue, 1 Sep 2015 18:07:41 +0200

> The temperature registers appear to report values in degrees Celsius
> while the hwmon API mandates values to be exposed in millidegrees
> Celsius. Do the conversion so that the values reported by "sensors"
> are correct.
> 
> Fixes: aed93e0bf493 ("tg3: Add hwmon support for temperature")
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied, thanks.

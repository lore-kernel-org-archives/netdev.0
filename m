From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 -next 4/4] tg3: Add binary sysfs file to export bulk
 sensor data
Date: Tue, 26 Jun 2012 21:02:25 -0700 (PDT)
Message-ID: <20120626.210225.1299243479273651339.davem@davemloft.net>
References: <1340758415-10746-2-git-send-email-mchan@broadcom.com>
	<1340758415-10746-3-git-send-email-mchan@broadcom.com>
	<1340758415-10746-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab2F0EC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 00:02:26 -0400
In-Reply-To: <1340758415-10746-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 26 Jun 2012 17:53:35 -0700

> The bulk of the sensor data is exported as binary data to sysfs for
> userspace access.
> 
> [binary sysfs suggested by Ben Hutchings <bhutchings@solarflare.com>]
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Ben stated merely that a binary attribute existed for sysfs files.  He
did not, however, say that this is the path down which you should
implement your feature.

He, instead, encoraged you to use hwmon and other generic interfaces
to export this sensor information.

I think you were eager to implement things this way because it was the
least amount of work on your part, and that disappoints me greatly.

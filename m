From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 -next 4/4] tg3: Add binary sysfs file to export bulk
 sensor data
Date: Tue, 26 Jun 2012 22:04:59 -0700 (PDT)
Message-ID: <20120626.220459.548918770401348569.davem@davemloft.net>
References: <1340758415-10746-4-git-send-email-mchan@broadcom.com>
	<20120626.210225.1299243479273651339.davem@davemloft.net>
	<1340773249.4344.74.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab2F0FFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:05:00 -0400
In-Reply-To: <1340773249.4344.74.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 26 Jun 2012 22:00:49 -0700

> On Tue, 2012-06-26 at 21:02 -0700, David Miller wrote:
>> Ben stated merely that a binary attribute existed for sysfs files.  He
>> did not, however, say that this is the path down which you should
>> implement your feature.
> 
> He said that if the data was difficult to parse in the driver, then a
> binary sysfs or private ioctl (which we would stay away) would be
> appropriate.  There are hundreds of bytes of this data, most of which is
> not useful to the user but needed for Lights out management.  It will
> greatly bloat the tg3 driver to add code to parse all that data and
> export each one separately.

I don't want us to get into the habit of just going "oh it's LOM
stuff, binary blob."  And that's the precedence you're setting here.

It also sets up a situation where functionality could end up only
being available in proprietary binary only tools.

It's not like this is some standardized format like a DMI table or
similar, is it?

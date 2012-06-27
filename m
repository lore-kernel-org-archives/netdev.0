From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v2 -next 4/4] tg3: Add binary sysfs file to export
 bulk sensor data
Date: Tue, 26 Jun 2012 22:12:09 -0700
Message-ID: <1340773929.4344.79.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1340758415-10746-4-git-send-email-mchan@broadcom.com>
 <20120626.210225.1299243479273651339.davem@davemloft.net>
 <1340773249.4344.74.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20120626.220459.548918770401348569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1805 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab2F0FMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 01:12:16 -0400
In-Reply-To: <20120626.220459.548918770401348569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 22:04 -0700, David Miller wrote: 
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Tue, 26 Jun 2012 22:00:49 -0700
> 
> > On Tue, 2012-06-26 at 21:02 -0700, David Miller wrote:
> >> Ben stated merely that a binary attribute existed for sysfs files.  He
> >> did not, however, say that this is the path down which you should
> >> implement your feature.
> > 
> > He said that if the data was difficult to parse in the driver, then a
> > binary sysfs or private ioctl (which we would stay away) would be
> > appropriate.  There are hundreds of bytes of this data, most of which is
> > not useful to the user but needed for Lights out management.  It will
> > greatly bloat the tg3 driver to add code to parse all that data and
> > export each one separately.
> 
> I don't want us to get into the habit of just going "oh it's LOM
> stuff, binary blob."  And that's the precedence you're setting here.
> 
> It also sets up a situation where functionality could end up only
> being available in proprietary binary only tools.

I will strongly encourage the OEM to opensource the userspace tool.  In
fact, we'll be writing it for them and we can influence them.

> 
> It's not like this is some standardized format like a DMI table or
> similar, is it?
> 

It is defined by the OEM.  I don't know whether they plan to publish it
or not, but I will check tomorrow.

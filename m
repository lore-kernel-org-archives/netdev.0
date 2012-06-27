From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v2 -next 4/4] tg3: Add binary sysfs file to export
 bulk sensor data
Date: Tue, 26 Jun 2012 22:00:49 -0700
Message-ID: <1340773249.4344.74.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1340758415-10746-2-git-send-email-mchan@broadcom.com>
 <1340758415-10746-3-git-send-email-mchan@broadcom.com>
 <1340758415-10746-4-git-send-email-mchan@broadcom.com>
 <20120626.210225.1299243479273651339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2879 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708Ab2F0FBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 01:01:05 -0400
In-Reply-To: <20120626.210225.1299243479273651339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 21:02 -0700, David Miller wrote:
> Ben stated merely that a binary attribute existed for sysfs files.  He
> did not, however, say that this is the path down which you should
> implement your feature.

He said that if the data was difficult to parse in the driver, then a
binary sysfs or private ioctl (which we would stay away) would be
appropriate.  There are hundreds of bytes of this data, most of which is
not useful to the user but needed for Lights out management.  It will
greatly bloat the tg3 driver to add code to parse all that data and
export each one separately.
> 
> He, instead, encoraged you to use hwmon and other generic interfaces
> to export this sensor information.

Temperature is useful to the user, defined by hwmon, and easily
extracted so we added this in patch #3.
> 
> I think you were eager to implement things this way because it was the
> least amount of work on your part, and that disappoints me greatly.
> 
Our purpose is not to bloat the tg3 driver unnecessarily. 
> 

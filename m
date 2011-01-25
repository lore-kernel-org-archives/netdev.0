From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] typhoon: Kill references to UTS_RELEASE
Date: Tue, 25 Jan 2011 12:33:04 -0800 (PST)
Message-ID: <20110125.123304.226768935.davem@davemloft.net>
References: <20110124.151214.28803162.davem@davemloft.net>
	<1295984365.11300.4.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751680Ab1AYUc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 15:32:29 -0500
In-Reply-To: <1295984365.11300.4.camel@lap75545.ornl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Tue, 25 Jan 2011 14:39:25 -0500

> On Mon, 2011-01-24 at 15:12 -0800, David Miller wrote:
>> I hereby declare this driver to have version "1.0"
> 
> Wish you'd gone to 1.6 or 2.0 since the last version before Joe's/my
> changes was 1.5.9, but it's pretty irrelevant anyways. Hmm, does
> anything complain if we just remove the MODULE_VERSION?

I don't think anything does, but it's presence helps distribution
vendors so they can add their own sub-version suffix to the driver
version when they make local changes.

And you really do want that when users report problems but are using
vendor kernels, it makes the fact that local changes exist from the
vendor easy to see.

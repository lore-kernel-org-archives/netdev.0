From: David Miller <davem@davemloft.net>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 12:41:31 -0700 (PDT)
Message-ID: <20060919.124131.130617144.davem@davemloft.net>
References: <20060918211759.GB31746@tentacle.sectorb.msk.ru>
	<20060918220038.GB14322@ms2.inr.ac.ru>
	<20060918220331.GB32520@tentacle.sectorb.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, ak@suse.de, hawk@diku.dk,
	harry@atmos.washington.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26280
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751037AbWISTl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 15:41:26 -0400
To: master@sectorb.msk.ru
In-Reply-To: <20060918220331.GB32520@tentacle.sectorb.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Date: Tue, 19 Sep 2006 02:03:31 +0400

> On Tue, Sep 19, 2006 at 02:00:38AM +0400, Alexey Kuznetsov wrote:
> > * I do see get_offset_pmtmr() in top lines of profile. That's scary enough.
> 
> I had it at the very top line.

That is just rediculious.

You can "fix" the networking by making it timestamp less but what
about things like just normal X11 clients that call gettimeofday()
at very high rates?

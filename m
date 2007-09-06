From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Thu, 06 Sep 2007 12:50:19 -0700 (PDT)
Message-ID: <20070906.125019.104036964.davem@davemloft.net>
References: <20070906.073423.74747465.davem@davemloft.net>
	<20070906154123.GC10317@gospo.rdu.redhat.com>
	<1189105530.4852.8.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:40864
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753441AbXIFTuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 15:50:24 -0400
In-Reply-To: <1189105530.4852.8.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 06 Sep 2007 12:05:30 -0700

> The HT1000 bridge may very well have an MSI issue.  I'm checking with
> ServerWorks and I will do some testing to confirm.  If confirmed, we can
> disable MSI behind the HT1000 bridge instead of globally.  The 5714
> issue is not caused by the HT1000 as it is not behind the HT1000.

What I'm going to do at this point is just merge the tg3
fix into the current 2.6.23 tree right now.

Meanwhile I'll have the HT1000 MSI quirk revert ready and,
unless we find a reason not to, I'll ask Greg KH to merge
that patch into 2.6.24

It seems the safest and most reasonable way to handle this
right now.

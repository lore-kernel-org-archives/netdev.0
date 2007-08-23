From: David Miller <davem@davemloft.net>
Subject: Re: eHEA driver issues from net-2.6.24
Date: Thu, 23 Aug 2007 01:17:10 -0700 (PDT)
Message-ID: <20070823.011710.01771014.davem@davemloft.net>
References: <20070822.150302.44981242.davem@davemloft.net>
	<46CCB696.7090703@us.ibm.com>
	<200708230855.29961.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: habanero@us.ibm.com, netdev@vger.kernel.org
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56067
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755373AbXHWIRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 04:17:12 -0400
In-Reply-To: <200708230855.29961.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Thu, 23 Aug 2007 08:55:29 +0200

> We'd like to keep the possibility to switch back to a single queue
> for now.

Please do not do this, we already have way too much configurability
out there.

If you have the physical hardware queues enabled, use multiqueue napi
support.

If you add a knob to use or not use multi-napi, this makes life
more miserable for your users and your driver more complicated
and harder to maintain.

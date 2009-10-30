From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Fri, 30 Oct 2009 11:11:14 -0700 (PDT)
Message-ID: <20091030.111114.119833365.davem@davemloft.net>
References: <20091030043050.GB3380@jenkins.home.ifup.org>
	<20091029.213816.35637194.davem@davemloft.net>
	<20091030083452.68ca227e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bphilips@suse.de, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48351
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932750AbZJ3SKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:10:50 -0400
In-Reply-To: <20091030083452.68ca227e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 30 Oct 2009 08:34:52 -0700

> Why not fix the problem in a generic way?

Drivers still need to make sure carrier is off when their
->open() routine runs, so that the transition event from
link down to link up occurs properly when the device is brought
up.

So mucking around with this carrier test will only hide the
bugs, not make things easier.

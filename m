From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Thu, 29 Oct 2009 21:12:19 -0700 (PDT)
Message-ID: <20091029.211219.182331672.davem@davemloft.net>
References: <20091029235807.GF3228@jenkins.home.ifup.org>
	<20091029200905.00f4c13d@nehalam>
	<20091030035128.GA3380@jenkins.home.ifup.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: bphilips@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750802AbZJ3ELz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 00:11:55 -0400
In-Reply-To: <20091030035128.GA3380@jenkins.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brandon Philips <bphilips@suse.de>
Date: Thu, 29 Oct 2009 20:51:28 -0700

> The right thing to do is up the interface first before looking at the
> the Link state, and I told them to do that, but I figured that this
> patch made sense too to fix the initial buglet.

It is not valid to expect link status before bringing the interface
up.

Otherwise, if link status is expected in this case, drivers cannot
fully power down all elements of the chip when the device is not even
brought up.

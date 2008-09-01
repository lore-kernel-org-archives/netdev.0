From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after some	time
Date: Sun, 31 Aug 2008 22:49:50 -0700
Message-ID: <OF94B2D0C1.33DB4CE6-ON882574B7.001FDB00-882574B7.00200870@us.ibm.com>
References: <20080831182034.GA12035@pest>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:59316 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbYIAFtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 01:49:55 -0400
In-Reply-To: <20080831182034.GA12035@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My wild guess is that you have lost the multicast bit on
the interface, by a daemon that is just setting the interface
flags rather than doing get/or in new/set.

When it's failing, you might try looking at the interface
flags to see if IFF_MULTICAST is still there.

                                +-DLS


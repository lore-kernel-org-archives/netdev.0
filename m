From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Bad tg3 performance on S10 netbook
Date: Wed, 14 Jan 2009 15:17:07 -0800
Message-ID: <1231975027.8964.136.camel@HP1>
References: <496E64BB.7080709@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Ben Greear" <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1766 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756631AbZANXVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 18:21:33 -0500
In-Reply-To: <496E64BB.7080709@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-01-14 at 14:18 -0800, Ben Greear wrote:
> We tried turning on adaptive-rx (it is off by default), and again,
> no improvement.

tg3 does not support adaptive-rx.  It will be quietly ignored by the
driver.  ethtool -c will show that it is always off after you try to
turn it on.



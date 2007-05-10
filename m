From: David Miller <davem@davemloft.net>
Subject: Re: Please pull 'upstream-rtl8187' branch of wireless-2.6
Date: Thu, 10 May 2007 04:36:12 -0700 (PDT)
Message-ID: <20070510.043612.112287450.davem@davemloft.net>
References: <46425564.3040505@garzik.org>
	<200705092216.26880.flamingice@sourmilk.net>
	<200705101323.41310.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: flamingice@sourmilk.net, jeff@garzik.org, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757562AbXEJLgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 07:36:09 -0400
In-Reply-To: <200705101323.41310.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>
Date: Thu, 10 May 2007 13:23:40 +0200

> Nah, Jeff. Please don't go this path.
> If we have to remove all magic numbers from drivers, we'd have to either
> *) Drop reverse engineered drivers like bcm43xx completely.
> *) Clutter them with completely useless defines such as
>    #define RADIO_UNKNOWN97A_REG	0x97A
> 
> Better leave such magic registers/values in the code as-is
> and probably convert them to good defines later, if reverse engineering
> found out the meaning. That's what I'm doing for bcm43xx and it makes
> a _whole_ lot more sense.

One good point I'd like to bring up is that someone reading this code
might not know any of this.

If you use a macro name that says it's a register you don't know the
meaning of, that's information and useful information at that.

This isn't for you, it's for other people reading the driver.

If you are suddenly unable to do any work on the driver at all, the
more information you leave around the better even if it seems trite
and useless to you.

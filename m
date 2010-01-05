From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Tue, 05 Jan 2010 12:40:40 -0800 (PST)
Message-ID: <20100105.124040.192660261.davem@davemloft.net>
References: <20091228194834.GA18422@hmsreliant.think-freely.org>
	<20100105135732.GA24245@hmsreliant.think-freely.org>
	<4B4357A9.5010507@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, romieu@fr.zoreil.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753780Ab0AEUkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 15:40:36 -0500
In-Reply-To: <4B4357A9.5010507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Jan 2010 16:15:53 +0100

> If hardware is buggy, driver should focus on security first,
> performance doesnt matter in this case.

Copying every packet is way too much of a performance hit to
accept.

Things are not so black and white, there are shades of grey.

We can fix this without making things so slow, try harder...

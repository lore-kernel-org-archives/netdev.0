From: David Miller <davem@davemloft.net>
Subject: Re: pktgen IP address stepping
Date: Thu, 16 Dec 2010 09:44:26 -0800 (PST)
Message-ID: <20101216.094426.193723178.davem@davemloft.net>
References: <20101216172800.GA8404@spritelink.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kristian@spritelink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49182
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756823Ab0LPRn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 12:43:58 -0500
In-Reply-To: <20101216172800.GA8404@spritelink.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Larsson <kristian@spritelink.net>
Date: Thu, 16 Dec 2010 18:28:00 +0100

> Looking forward to any feedback and / or suggestions.

If you need a huge type for the step values in order to handle ipv6
addresses or similar, used a fixed sized type such as "u64" instead of
"unsigned long long".

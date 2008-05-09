From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 09 May 2008 15:45:38 -0700 (PDT)
Message-ID: <20080509.154538.28321777.davem@davemloft.net>
References: <4824CBA1.8040703@sun.com>
	<4824CCF0.5050302@krogh.cc>
	<4824D1E1.10007@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37469
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752949AbYEIWpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:45:44 -0400
In-Reply-To: <4824D1E1.10007@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Fri, 09 May 2008 15:36:17 -0700

> I have observed TX throughput degradation (and increased CPU 
> utilization)  occurs with increased # of connections, when CPU count > 4 
> CPUs.  I don't think it is related to the driver (or HW).

All transmits through a device are fully serialized currently,
it's a known problem and something we plan to fix.

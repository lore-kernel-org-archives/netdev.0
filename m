From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic, ip_route_input, 2.6.25-rc6-git2
Date: Sun, 23 Mar 2008 03:11:39 -0700 (PDT)
Message-ID: <20080323.031139.17629653.davem@davemloft.net>
References: <20080323073638.M89709@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45930
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755676AbYCWKL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 06:11:29 -0400
In-Reply-To: <20080323073638.M89709@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Date: Sun, 23 Mar 2008 09:36:38 +0200

> Recently tested, it crashes also -git6 without lockdep compiled. So it seems 
> actually networking code bug.

I'm still not so sure.

The IP is at ip_route_input but the rest of your backtrace
shows an entirely different code path.

Nothing in the trace matches up, which severely decreases the
usability of the debugging information you've provided.
 

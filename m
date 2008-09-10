From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] niu: panic on reset
Date: Wed, 10 Sep 2008 13:28:08 -0700 (PDT)
Message-ID: <20080910.132808.242997035.davem@davemloft.net>
References: <48C07564.3060306@Sun.COM>
	<20080908.132031.65821182.davem@davemloft.net>
	<48C7FD76.2000206@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Santwona.Behera@Sun.COM, netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751901AbYIJU2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 16:28:15 -0400
In-Reply-To: <48C7FD76.2000206@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Wed, 10 Sep 2008 10:01:42 -0700

> Instead of creating a new function, Santwona was borrowing an existing
> logic from niu_change_mtu function. Rather than introducing a new
> function and possibly a new failure mode, we were trying to re-use existing
> logic, reducing the probability of a new bug.

But in essence the patch does add a new failure mode.  It now can fail
if a memory allocation cannot succeed at the current point in time.

That was not true previously, and if you just fix up the buffer pointers
or whatever state to be reset, you won't have this possible failure mode
either.

We should fix this correctly.

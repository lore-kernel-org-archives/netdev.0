From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH [Bug 8756]] IPv6: Don't update ADVMSS on routes where
 the MTU is not also updated
Date: Thu, 26 Jul 2007 00:10:13 -0700 (PDT)
Message-ID: <20070726.001013.07453787.davem@davemloft.net>
References: <20070714214831.d9def8c6.akpm@linux-foundation.org>
	<4699D5C7.2090906@simon.arlott.org.uk>
	<46A500B9.3030702@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: simon@fire.lp0.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760029AbXGZHKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 03:10:14 -0400
In-Reply-To: <46A500B9.3030702@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Arlott <simon@fire.lp0.eu>
Date: Mon, 23 Jul 2007 20:25:45 +0100

> The ADVMSS value was incorrectly updated for ALL routes when the MTU 
> is updated because it's outside the effect of the if statement's 
> condition.
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

Thanks for fixing this bug Simon, patch applied.

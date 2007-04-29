From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 8342] New: sctp_getsockopt_local_addrs_old()
 calls copy_to_user() while a spinlock is held
Date: Sat, 28 Apr 2007 21:14:18 -0700 (PDT)
Message-ID: <20070428.211418.38713510.davem@davemloft.net>
References: <462CF047.3050809@hp.com>
	<20070425.215405.110014911.davem@davemloft.net>
	<4630A783.4050200@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, matthias.kaehlcke@gmail.com,
	lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34057
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751789AbXD2EOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 00:14:14 -0400
In-Reply-To: <4630A783.4050200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 26 Apr 2007 09:22:11 -0400

> Here is an updated patch.  bytes_copied got turned into an int
> everywhere since that is what the new API expects, so it should be
> enough for the old api as well.  This also makes the code more
> consistent.

Applied, thanks Vlad.

From: Komuro <komurojun-mbn@nifty.com>
Subject: [PLEASE REVERT]  "Add a WARN_ON_ONCE" at  net/sched/sch_generic.c:
Date: Sun, 25 May 2008 11:23:08 +0900
Message-ID: <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defg500.nifty.com ([202.248.238.127]:25045 "EHLO
	defg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbYEYCkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2008 22:40:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Please revert the patch "Add a WARN_ON_ONCE() to
 the transmit timeout function".

The transmit timeout sometimes happens on normal operation.
This message annoys me.


>net: Add a WARN_ON_ONCE() to the transmit timeout function
>
>WARN_ON_ONCE() gives a stack trace including the full module list.
>Having this in the kernel dump for the timeout case in the
>generic netdev watchdog will help us see quicker which driver
>is involved. It also allows us to collect statistics
>and patterns in terms of which drivers have this event occuring.
>
>Suggested by Andrew Morton
>
>Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
>Signed-off-by: David S. Miller <davem@davemloft.net>

Best Regards
Komuro


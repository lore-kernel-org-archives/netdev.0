From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8961] New: BUG triggered by oidentd in netlink
 code
Date: Sat, 01 Sep 2007 18:38:23 +0200
Message-ID: <46D9957F.4020101@trash.net>
References: <bug-8961-10286@http.bugzilla.kernel.org/> <20070830180842.7c8414fe.akpm@linux-foundation.org> <Pine.LNX.4.64.0708311258520.8423@x2> <20070831123825.GW22067@miggy.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Athanasius <link@miggy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60291 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbXIAQif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 12:38:35 -0400
In-Reply-To: <20070831123825.GW22067@miggy.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Athanasius wrote:
>   I'll compile up a new kernel, likely 2.6.22.6, plus this patch, and
> reboot to it tonight.  I still don't know *exactly* how to trigger the
> bug on demand though, it's not reocurred since I posted the bug report
> (but had happened about a week before as well).


Thanks. I'm not sure either, it would require two concurrent requests
to be processed, but AFAICS oidentd only uses a single netlink socket.
Perhaps multiple running instances or something else using the inet_diag
interface?

You might be able to trigger it without this patch by running
"while true; do ss -tn; done" while doing ident queries, but
just running the while loop a couple of times in parallel
doesn't seem to trigger it here.


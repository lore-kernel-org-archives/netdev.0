From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [atl2] warn_slowpath in dev_watchdog
Date: Sun, 25 Jan 2009 21:00:17 -0600
Message-ID: <20090125210017.04e38348@osprey.hogchain.net>
References: <gkt97e$ti0$1@ger.gmane.org>
	<20090117194045.649f55a0@osprey.hogchain.net>
	<767752.95325.qm@web110601.mail.gq1.yahoo.com>
	<20090118095231.2c73c448@osprey.hogchain.net>
	<879024.62535.qm@web110609.mail.gq1.yahoo.com>
	<20090118115858.1b636b2d@osprey.hogchain.net>
	<884897.63360.qm@web110608.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Sitsofe Wheeler <sitsofe@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f21.google.com ([209.85.217.21]:49815 "EHLO
	mail-gx0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbZAZDAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 22:00:22 -0500
In-Reply-To: <884897.63360.qm@web110608.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Jan 2009 08:17:25 -0800 (PST)
Sitsofe Wheeler <sitsofe@yahoo.com> wrote:

> OK the circumstances took a lllllong time to occur again but the result is that
> the patch does not prevent the warning. 

Can you trigger the warning by performing these steps while the interface is up?

unplug cable
ifdown eth0
ifup eth0
replug cable       
wait about 5 seconds...

If it doesn't happen the first time, try 3 or 4 more times.

Let me know what happens.

Thanks,
Jay

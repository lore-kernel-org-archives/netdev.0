From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Documentation: rw_lock lessons learned
Date: Fri, 13 Nov 2009 09:59:29 +0100
Message-ID: <4AFD1FF1.7080906@s5r6.in-berlin.de>
References: <4AF9C540.5090403@gmail.com>	<20091110180646.2e5859a8@nehalam>	<4AFAEF78.4080807@gmail.com>	<20091111093724.4f40a48d@nehalam>	<4AFBEC44.9030409@gmail.com>	<4AFC5E3F.7070609@earthlink.net> <20091112150029.1a26c641@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: sclark46@earthlink.net,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:51661 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754659AbZKMI7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 03:59:44 -0500
In-Reply-To: <20091112150029.1a26c641@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 12 Nov 2009 14:13:03 -0500
> Stephen Clark <sclark46@earthlink.net> wrote:
>> How up to date is this doc?
>> 
>> http://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/index.html
>> 
> 
> Out of date.
> 1. Missing mutex's which have largely replaced semaphores.
> 
> 2. Missing change to lock initialization in later kernels.
> 
> 3. Missing description of lock dependency checker which should be in same guide.

4. The section on atomic reference counting should refer to <linux/kref.h>.
-- 
Stefan Richter
-=====-==--= =-== -==-=
http://arcgraph.de/sr/

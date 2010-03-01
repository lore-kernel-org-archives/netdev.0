From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Mon, 01 Mar 2010 10:17:07 +0800
Message-ID: <1267409827.23196.44.camel@debian>
References: <1267067593.16986.1583.camel@debian>
	 <1267097080.2822.14.camel@edumazet-laptop>
	 <1267151683.16986.1646.camel@debian>
	 <1267189945.2822.1572.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shi, Alex" <alex.shi@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51218 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753186Ab0CACPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2010 21:15:30 -0500
In-Reply-To: <1267189945.2822.1572.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-26 at 21:12 +0800, Eric Dumazet wrote:
> Well, if you have one processor, and a process doesnt want to yield
> the cpu (apart of sofirq of course that is filling the backlog while
> your process tries to empty it), your machine is dead. This is
> critical too :) 

If you only have one CPU, this won't happen. Because while the receiver
is busy processing the backlog, no senders will have the chance to be
scheduled to Tx more. And with the limited backlog, it won't take long
for the receiver to finish processing all the frames in the backlog.

Thanks,
-yi


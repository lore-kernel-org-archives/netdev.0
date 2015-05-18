From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib
 offload on failure to program fib entry in hardware
Date: Mon, 18 May 2015 16:19:16 -0400 (EDT)
Message-ID: <20150518.161916.2132217836491222672.davem@davemloft.net>
References: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, john.fastabend@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932168AbbERUTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:19:19 -0400
In-Reply-To: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Sun, 17 May 2015 16:42:05 -0700

> On most systems where you can offload routes to hardware,
> doing routing in software is not an option (the cpu limitations
> make routing impossible in software).

You absolutely do not get to determine this policy, none of us
do.

What matters is that by default the damn switch device being there
is %100 transparent to the user.

And the way to achieve that default is to do software routes as
a fallback.

I am not going to entertain changes of this nature which fail
route loading by default just because we've exceeded a device's
HW capacity to offload.

I thought I was _really_ clear about this at netdev 0.1

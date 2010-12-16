From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Thu, 16 Dec 2010 15:17:36 -0800
Message-ID: <m1y67ptii7.fsf@fess.ebiederm.org>
References: <4D00F58A.2050307@hp.com> <m139q6ahld.fsf@fess.ebiederm.org>
	<20101209111611.1d2e6e2b@nehalam>
	<20101209.122033.183046393.davem@davemloft.net>
	<20101216132812.2d7fd885@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brian.haley@hp.com,
	netdev@vger.kernel.org, maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40926 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab0LPXRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 18:17:45 -0500
In-Reply-To: <20101216132812.2d7fd885@nehalam> (Stephen Hemminger's message of
	"Thu, 16 Dec 2010 13:28:12 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> When loopback device is being brought down, then keep the route table
> entries because they are special. The entries in the local table for
> linklocal routes and ::1 address should not be purged.
>
> This is a sub optimal solution to the problem and should be replaced
> by a better fix in future.

I will test this and let you know how it goes from my side.

I would really like to get a fix for this in before -rc7,
as this bug makes the kernel unusable for me.

Eric

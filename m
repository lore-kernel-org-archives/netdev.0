From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Thu, 16 Dec 2010 18:26:56 -0800 (PST)
Message-ID: <20101216.182656.226781473.davem@davemloft.net>
References: <20101209.122033.183046393.davem@davemloft.net>
	<20101216132812.2d7fd885@nehalam>
	<m1mxo5tcx6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, brian.haley@hp.com, netdev@vger.kernel.org,
	maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33689
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750943Ab0LQC02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 21:26:28 -0500
In-Reply-To: <m1mxo5tcx6.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 16 Dec 2010 17:18:13 -0800

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
>> When loopback device is being brought down, then keep the route table
>> entries because they are special. The entries in the local table for
>> linklocal routes and ::1 address should not be purged.
>>
>> This is a sub optimal solution to the problem and should be replaced
>> by a better fix in future.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Stephen thanks for this.  This patch looks good to me.  I just tested
> this against 2.6.37-rc6 and my simple tests show it to be working
> without problems.
> 
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied to net-2.6, thanks everyone.

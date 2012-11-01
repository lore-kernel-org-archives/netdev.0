From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 1/1] ptp: add an ioctl to compare PHC time
 with system time
Date: Thu, 01 Nov 2012 11:42:50 -0400 (EDT)
Message-ID: <20121101.114250.1910261241261512173.davem@davemloft.net>
References: <cover.1351696507.git.richardcochran@gmail.com>
	<cover.1351696507.git.richardcochran@gmail.com>
	<7701f1fd27692810e7948363344238287b9458c2.1351696507.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.stultz@linaro.org, mlichvar@redhat.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761922Ab2KAPmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 11:42:54 -0400
In-Reply-To: <7701f1fd27692810e7948363344238287b9458c2.1351696507.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 31 Oct 2012 17:19:07 +0100

> This patch adds an ioctl for PTP Hardware Clock (PHC) devices that allows
> user space to measure the time offset between the PHC and the system
> clock. Rather than hard coding any kind of estimation algorithm into the
> kernel, this patch takes the more flexible approach of just delivering
> an array of raw clock readings. In that way, the user space clock servo
> may be adapted to new and different hardware clocks.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> Acked-by: Jacob Keller <jacob.e.keller@intel.com>

Applied.

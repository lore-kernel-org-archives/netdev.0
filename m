From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH RFC net-next 4/4] time: remove the timecompare code.
Date: Fri, 28 Sep 2012 10:44:16 -0700
Message-ID: <5065E1F0.3000202@linaro.org>
References: <cover.1348851539.git.richardcochran@gmail.com> <e100d86136270dae62ff546e3a6c5ef10631c68c.1348851539.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, device-drivers-devel@blackfin.uclinux.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mike Frysinger <vapier@gentoo.org>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Patrick Ohly <patrick.ohly@intel.com>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:33557 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab2I1RpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 13:45:07 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <john.stultz@linaro.org>;
	Fri, 28 Sep 2012 11:45:06 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D58D31FF0039
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 11:44:39 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8SHiWtV072060
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 11:44:32 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8SHiO0N031751
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 11:44:29 -0600
In-Reply-To: <e100d86136270dae62ff546e3a6c5ef10631c68c.1348851539.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2012 10:20 AM, Richard Cochran wrote:
> This patch removes the timecompare code from the kernel. The top five
> reasons to do this are:
>
> 1. There are no more users of this code.
> 2. The original idea was a bit weak.
> 3. The original author has disappeared.
> 4. The code was not general purpose but tuned to a particular hardware,
> 5. There are better ways to accomplish clock synchronization.
>
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Nice cleanup!

Acked-by: John Stultz <john.stultz@linaro.org>

thanks!
-john

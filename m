From: Anders =?iso-8859-1?Q?Bostr=F6m?= <anders@netinsight.net>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Tue, 02 Apr 2013 14:22:22 +0200 (CEST)
Message-ID: <20130402.142222.677899453679103897.anders@netinsight.net>
References: <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk>
	<20130402.093504.1785848735327620554.anders@netinsight.net>
	<20130402094102.GD4924@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, Jie.Yang@Atheros.com, netdev@vger.kernel.org,
	565404@bugs.debian.org, Xiong.Huang@Atheros.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:46873 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755897Ab3DBMWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 08:22:30 -0400
In-Reply-To: <20130402094102.GD4924@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "HFS" == Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

 HFS> The bug is definitely still around. Yesterday I could reproduce it and will
 HFS> look for a solution in the next days.

This sounds great!

 HFS> Do you have any details on the hangs every 6 months? Could you catch
 HFS> thread dumps or oopses?

As I wrote, the computer is a live file-server, so we have restarted
the computer as soon as possible when this has occured, and currently
use an Intel NIC instead.

The following was logged when the hang occured:

May 19 12:50:32 flash kernel: [12182478.782248] ATL1E 0000:03:00.0: atl1e_clean is called when AT_DOWN
...
Dec  8 15:00:28 flash kernel: [5282450.781172] ATL1E 0000:03:00.0: atl1e_clean is called when AT_DOWN

/ Anders

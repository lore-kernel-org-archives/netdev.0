From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0/2] [iputils] MTU discovery changes
Date: Mon, 09 Apr 2007 13:15:51 +0900 (JST)
Message-ID: <20070409.131551.71672383.yoshfuji@linux-ipv6.org>
References: <460474E1.9070805@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40961 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbXDIEOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 00:14:54 -0400
In-Reply-To: <460474E1.9070805@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <460474E1.9070805@psc.edu> (at Fri, 23 Mar 2007 20:46:25 -0400), John Heffner <jheffner@psc.edu> says:

> These add some changes that make tracepath a little more useful for 
> diagnosing MTU issues.  The length flag helps distinguish between MTU 
> black holes and other types of black holes by allowing you to vary the 
> probe packet lengths.  Using PMTUDISC_PROBE gives you the same results 
> on each run without having to flush the route cache, so you can see 
> where MTU changes in the path actually occur.
> 
> The PMTUDISC_PROBE patch goes in should be conditional on whether the 
> corresponding kernel patch (just sent) goes in.

Applied, thanks.

--yoshfuji

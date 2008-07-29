From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Tue, 29 Jul 2008 19:11:10 +0300
Message-ID: <200807291911.10364.opurdila@ixiacom.com>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com> <1217343163.30512.34.camel@ecld0pohly> <20080729085457.033a9fd2@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:20302 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750712AbYG2QNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 12:13:41 -0400
In-Reply-To: <20080729085457.033a9fd2@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 29 July 2008, Stephen Hemminger wrote:
>
> In my sky2 sample code, I took a different approach:
>  1. Why have HW timestamps different than existing timestamps? If you
>     just use existing timestamp, no socket API is needed.

I agree that is a much better approach if you are ok with the variance 
introduced by synchronizing the HW timestamps with the CPU clock.

But if you want to precisely measure one-way delays, and if you have the hw 
timestamp units synchronized across the nodes, then you need the hardware 
timesetamp. 

Or maybe I am stuck on this idea because of doing things this way for a long 
time and there is a better solution?

Thanks,
tavi

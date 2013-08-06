From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: [PATCH net] net: rename and move busy poll mib counter
Date: Tue, 6 Aug 2013 13:18:21 -0500
Message-ID: <20130806181821.GB8993@sbohrermbp13-local.rgmadvisors.com>
References: <20130806095207.5887.2196.stgit@ladj378.jer.intel.com>
 <1375784088.4457.74.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:43972 "EHLO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756170Ab3HFSSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 14:18:25 -0400
Received: by mail-oa0-f42.google.com with SMTP id i18so1470528oag.29
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 11:18:24 -0700 (PDT)
In-Reply-To: <1375784088.4457.74.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 03:14:48AM -0700, Eric Dumazet wrote:
> On Tue, 2013-08-06 at 12:52 +0300, Eliezer Tamir wrote:
> > Move the low latency mib counter to the ip section.
> > Rename it from low latency to busy poll.
> > 
> > Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> > Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> > ---
> 
> Well, it should not be part of IP mib, but a socket one (not existing so
> far)
> 
> Linux MIB already contains few non TCP counters :
> 
> LINUX_MIB_ARPFILTER
> LINUX_MIB_IPRPFILTER

Doesn't mean they are in the correct place either, but perhaps it's too
late for them.

> Its mostly populated by TCP counters, sure.

See, on the kernel side these are called "LINUX_MIB*" which seems
perfectly sane and I wouldn't even think the statistic is out of
place.  On the user-mode side these are all reported in
/proc/net/netstat as TcpExt statistics.  I can tell you that I don't
look at TCP statistics when I'm debugging/testing UDP issues
(apparently I should).

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.

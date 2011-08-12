From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: iproute2: make arpd daemon write pid file on fork
Date: Fri, 12 Aug 2011 09:15:47 -0700
Message-ID: <20110812091547.17c40798@nehalam.ftrdhcpuser.net>
References: <1313080925.3635.YahooMailNeo@web121018.mail.ne1.yahoo.com>
	<20110811110029.023a5955@nehalam.ftrdhcpuser.net>
	<201108121623.24984.oakad@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alex Dubov <oakad@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43070 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751542Ab1HLQQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 12:16:07 -0400
In-Reply-To: <201108121623.24984.oakad@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Aug 2011 16:23:24 +1000
Alex Dubov <oakad@yahoo.com> wrote:

> Current version of arpd included with iproute2-2.6.37 will fork 
> unconditionally on start-up (using daemon() library call). This causes 
> problems with distro start-up scripts, as PID of the started daemon can not be 
> reliably obtained, hampering orderly daemon shutdown process.
> 
> The included patch makes arpd write it's own pid file after fork, in a common 
> LSB fashion, so as to better inter-operate with start up scripts. Removal of 
> stale pid files is handled elsewhere.

I already checked in a version which has the -p pidfile option.

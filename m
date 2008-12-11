From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [Bugme-new] [Bug 12201] New: long wait in call_usermodehelper() / queue_work() / wait_for_completion()
Date: Fri, 12 Dec 2008 01:51:58 +0300
Message-ID: <20081211225158.GA2169@ioremap.net>
References: <bug-12201-10286@http.bugzilla.kernel.org/> <20081211143758.510b51b6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mike@nauticaltech.com, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:45112 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757459AbYLKWwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 17:52:00 -0500
Content-Disposition: inline
In-Reply-To: <20081211143758.510b51b6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Dec 11, 2008 at 02:37:58PM -0800, Andrew Morton (akpm@linux-foundation.org) wrote:
> > If I write a small pilot program that calls socket(PF_NETLINK, SOCK_RAW,
> > NETLINK_AUDIT), it will delay by 1-2 seconds 100% of the time (assuming server
> > has been online for a while).  Certain protocol types given to socket() have
> > zero delay (because no module needs to be loaded).
> > 
> > Steps to reproduce:
> > Once server has been online for a while, a simple call to socket(PF_NETLINK,
> > SOCK_RAW, NETLINK_AUDIT) shows the problem.
> 
> OK, weird.
> 
> Please get sysrq working then get us a task trace, so we can see who is
> sleeping where.  Do this:
> 
> 
> - run your "small pilot program"

Or send it to us and we will quickly fix the bug :)

Thank you!

-- 
	Evgeniy Polyakov

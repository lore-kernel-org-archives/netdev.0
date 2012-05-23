From: Dave Jones <davej@redhat.com>
Subject: Re: NETDEV WATCHDOG: %s (%s): transmit queue %u timed out
Date: Tue, 22 May 2012 21:26:40 -0400
Message-ID: <20120523012640.GB15255@redhat.com>
References: <20120523010334.5778.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758705Ab2EWB0p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 21:26:45 -0400
Content-Disposition: inline
In-Reply-To: <20120523010334.5778.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 22, 2012 at 09:03:34PM -0400, George Spelvin wrote:
 > After installing a 3.4 kernel, I got the following:
 > 
 > ------------[ cut here ]------------
 > WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0xe9/0x15c()
 > Hardware name: MS-7376
 > NETDEV WATCHDOG: inside (r8169): transmit queue 0 timed out
 > Pid: 0, comm: swapper/3 Not tainted 3.4.0-00017-g3df9c78 #152
 > ..
 > It doesn't seem to be causing serious problems, but I presume the warning is there because
 > someone would like to know about it.

We seem to be seeing more and more of these (across a range of different NICs)
https://bugzilla.redhat.com/showdependencytree.cgi?id=702723&hide_resolved=1
has a bunch of duplicated bugs sorted into per-nic reports.

	Dave

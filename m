From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iw lockdep warning on wireless-testing
Date: Tue, 24 Jun 2008 17:03:19 +0200
Message-ID: <48610CB7.5030705__2552.77131586826$1214322549$gmane$org@gmail.com>
References: <1214293174.14590.229.camel@debian.sh.intel.com>	 (sfid-20080624_094030_856715_6751BF69)  <1214297955.8967.258.camel@johannes.berg> <1214298350.14590.238.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg
	<public-johannes-cdvu00un1VgdHxzADdlk8Q@hugh.gmane.org>,
	public-linux-wireless-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org,
	Thomas Graf <public-tgraf-G/eBtMaohhA@hugh.gmane.org>,
	netdev <public-netdev-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org>
To: Zhu Yi <public-yi.zhu-ral2JQCrhuEAvxtiuMwx3w@hugh.gmane.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blaine.gmane.org ([80.91.229.8]:47631 "EHLO hugh.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198AbYFXPr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 11:47:56 -0400
Received: from public by hugh.gmane.org with local (Exim 4.63)
	(envelope-from <public@hugh.gmane.org>)
	id 1KBA7C-0001us-TY
	for netdev@vger.kernel.org; Tue, 24 Jun 2008 17:07:26 +0200
In-Reply-To: <1214298350.14590.238.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




Zhu Yi wrote, On 06/24/2008 11:05 AM:

> On Tue, 2008-06-24 at 10:59 +0200, Johannes Berg wrote:
>>> [ INFO: possible circular locking dependency detected ]
>>> 2.6.26-rc6-wl #57
>>> -------------------------------------------------------
>>> iw/2763 is trying to acquire lock:
>>>  (genl_mutex){--..}, at: [<ffffffff81216e4c>] ctrl_dumpfamily
>> +0x31/0xf7
>>> but task is already holding lock:
>>>  (nlk->cb_mutex){--..}, at: [<ffffffff812137c8>] netlink_dump
>> +0x40/0x19d
>>> which lock already depends on the new lock.
>> None of those is anything nl80211 has influence over, afaict.
> 
> Agreed. I can follow the two scenarios below. Apparently it's a ABBA
> locking issue. Just don't know which should be the correct sequence for
> using with the two locks.
> 

It should be fixed by this patch:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=6d1a3fb567a728d31474636e167c324702a0c38b

Regards,
Jarek P.



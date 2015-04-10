From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5 v2] netfilter: Fix format string of nfnetlink_log
 proc file
Date: Fri, 10 Apr 2015 12:40:27 -0700 (PDT)
Message-ID: <20150410.124027.1369874709878370130.davem@davemloft.net>
References: <1428616637-21690-5-git-send-email-richard@nod.at>
	<1428619177.5413.15.camel@perches.com>
	<55277C47.4080201@nod.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, rostedt@goodmis.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, kadlec@blackhole.kfki.hu,
	kaber@trash.net, pablo@netfilter.org
To: richard@nod.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbDJTbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 15:31:18 -0400
In-Reply-To: <55277C47.4080201@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Weinberger <richard@nod.at>
Date: Fri, 10 Apr 2015 09:31:19 +0200

> Am 10.04.2015 um 00:39 schrieb Joe Perches:
>> On Thu, 2015-04-09 at 23:57 +0200, Richard Weinberger wrote:
>>> The printed values are all of type unsigned integer, therefore use
>>> %u instead of %d. Otherwise an user can face negative values.
>> 
>> Hey Richard.
>> 
>> Just to clarify, this patch is for net and not for net-next
>> as net-next has removed the seq_printf return uses.
>> 
>> Are you going to submit an equivalent patch for net-next?
> 
> Hmm, you are right. It took me a few minutes to figure out what happened
> because I did rebase my patches to net-next and fixed up 5/5 already.
> Reading yesterday's bash history shows that I've used
> git format-patch in a wrong way such that the comments from the old
> branch were taken.

I'm waiting for you to respin this series against net-next, thanks.

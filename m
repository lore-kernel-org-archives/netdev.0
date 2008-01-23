From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: My 802.3ad is my bond
Date: Wed, 23 Jan 2008 09:13:25 -0800
Message-ID: <26889.1201108405@death>
References: <1201103100.22038.254.camel@quoit>
Cc: netdev@vger.kernel.org
To: Steven Whitehouse <swhiteho@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:58397 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861AbYAWRNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 12:13:44 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0NHDhJx000452
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 12:13:43 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NHDVvY083614
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 10:13:36 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0NHDVqj021485
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 10:13:31 -0700
In-reply-to: <1201103100.22038.254.camel@quoit> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steven Whitehouse <swhiteho@redhat.com> wrote:
[...]
>This commit: ece95f7fefe3afae19e641e1b3f5e64b00d5b948 seems to have
>caused a problem with parsing bond arguments as now only the numeric
>arguments seem to work (in modprobe.conf) and specifying 802.3ad fails.
>When I revert that patch in my local tree all seems ok.

	Thanks for the report; I know what the problem here is.  I'll
get a fix out.

>Also I notice that one of my two NICs now reports this:
>
>bonding: bond0: link status definitely down for interface eth0,
>disabling it
>bonding: bond0: Interface eth0 is already enslaved!
>bond0.5: no IPv6 routers present
>
>which I think is also new with this set of bonding updates, before it
>used to use both interfaces ok. I've not worked out which of the other
>patches causes this so far, but I can if its helpful,

	That would be helpful, as would some more details: e.g., the
various options passed to bonding, the complete dmesg log, contents of
/proc/net/bonding/bond0 [or whatever your interface is called], and
anything else you think would be helpful.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

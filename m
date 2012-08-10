From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 7/8] bridge: add some comments for NETDEV_RELEASE
Date: Fri, 10 Aug 2012 12:59:12 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1208101257010.10147@frira.zrqbmnf.qr>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>  <1344263012-4031-8-git-send-email-amwang@redhat.com>  <20120806.135003.442648448779232464.davem@davemloft.net> <1344296345.2026.3.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, amwang@redhat.com,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([5.9.24.206]:41444 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120Ab2HJK7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 06:59:14 -0400
In-Reply-To: <1344296345.2026.3.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2012-08-07 01:39, Joe Perches wrote:
>On Mon, 2012-08-06 at 13:50 -0700, David Miller wrote:
>> > +	/*
>> > +	 * We don't notify NETDEV_RELEASE event, as this will
>> > +	 * stop netconsole on the bridge.
>> > +	 */
>> 
>> Please format comments in the networking:
>> 
>> 	/* Like
>> 	 * this.
>> 	 */
>
>Maybe add a networking specific block comment style
>to checkpatch. This doesn't trigger on files outside
>of drivers/net and net.

Is there any particular reason why net/ wants to be special?
Before we know it, coding style is like laws across US states..

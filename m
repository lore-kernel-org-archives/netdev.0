From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 06 Jun 2007 10:13:36 -0600
Message-ID: <m14plluklr.fsf@ebiederm.dsl.xmission.com>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<m1tztlvrsp.fsf@ebiederm.dsl.xmission.com>
	<46669FA0.3030405@trash.net>
	<m1d509umtp.fsf@ebiederm.dsl.xmission.com>
	<4666D426.2070606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40711 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755552AbXFFQPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 12:15:48 -0400
In-Reply-To: <4666D426.2070606@trash.net> (Patrick McHardy's message of "Wed,
	06 Jun 2007 17:35:02 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

>> I still think adding a IFLA_PARTNER or a custom attribute is cleaner
>> in this case.  Slight semantic mismatches are the worst design bugs
>> to correct.
>
>
> Indeed, IFLA_PARTNER sounds like a better idea. I just suggested to
> Pavel to create only a single device per newlink operation and binding
> them later, what do you think about that?

I don't think it solves much because we still need a way to report the
partner device.

On the actual using side I think it makes the core of the driver much
more difficult to get right.  

Basically if we can't count on having a partner device we have to
add NULL pointer checks and locking to the packet dispatch which
is otherwise unnecessary.

Eric


From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Sat, 23 Jan 2010 20:33:56 +0100
Message-ID: <m2my04d3a3.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-8-git-send-email-sam@synack.fr>
	<4B420464.3040301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob75-7-88-160-5-175.fbx.proxad.net ([88.160.5.175]:43980 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887Ab0AWTd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 14:33:58 -0500
In-Reply-To: <4B420464.3040301@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 16:08:20 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Samir Bellabes wrote:
>> +++ b/security/snet/include/snet_netlink.h
>> @@ -0,0 +1,201 @@
>> +#ifndef _SNET_NETLINK_H
>> +#define _SNET_NETLINK_H
>> +
>> +#include <linux/in6.h>
>> +#include "snet_hooks.h"
>> +
>> +extern unsigned int snet_verdict_delay;
>
> As this file defines the userspace interface, it probably shouldn't
> contain declarations of kernel-internal variables (same for
> snet_hooks.h). It would also be better placed in include/linux as
> the other netlink API definitions.

sorry the the delay on this.
indeed, this is fixed now, thanks Patrick

sam

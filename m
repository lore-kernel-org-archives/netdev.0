From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [RFC patch net-next-2.6] net: introduce ethernet teaming device
Date: Mon, 3 Oct 2011 13:37:06 +0200
Message-ID: <20111003113705.GC2140@minipsycho.brq.redhat.com>
References: <1317386643-3041-1-git-send-email-jpirko@redhat.com>
 <CAEP_g=8uJnngfKJRGLLnd8U7M9aJTfOSUheB62-O7OX6Ud0DLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520Ab1JCLhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Oct 2011 07:37:48 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8uJnngfKJRGLLnd8U7M9aJTfOSUheB62-O7OX6Ud0DLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 01, 2011 at 08:15:01PM CEST, jesse@nicira.com wrote:
>On Fri, Sep 30, 2011 at 5:44 AM, Jiri Pirko <jpirko@redhat.com> wrote:
>> This patch introduces new network device called team. It supposes to be
>> very fast, simple, userspace-driven parallel to existing bonding device.
>> Userspace library called libteam with couple of demo apps is available
>> here:
>> https://github.com/jpirko/libteam
>> Note it's still in its dipers atm.
>>
>> team<->libteam use generic netlink for communication. That and rtnl
>> suppose to be the only way to configure team device, no sysfs etc.
>>
>> In near future python binding for libteam will be introduced. Also
>> daemon providing arpmon/miimon active-backup functionality will
>> be introduced. All what's necessary is already implemented in kernel team
>> driver.
>>
>> Plan is to support 8023ad in near future with it's logic mainly in
>> userspace daemon as well.
>>
>> Please review, try, comment. All feedback would be much appreciated.
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>Not to push my own agenda too much but you might want to take a look
>at Open vSwitch.  It uses the same strategy of userspace directed
>bonding and already supports active-backup, 802.3ad, and quite a few
>other networking tools all controlled by userspace.
>
>I know there's been a lot of talk and not a lot of action when it
>comes to upstreaming but that's changing.  We're fixing up a few loose
>ends in the userspace/kernel interface and then intend to propose a
>patch fairly soon.

Looks interesting. From quick peak the code is much bigger and fairly
complicated. The main reason for doing "team" is to do ethernet teaming
in as much simple way as it can be done. Final user destination areas
of openvswitch and team seem different to me.

Jirka

From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC patch net-next-2.6] net: introduce ethernet teaming device
Date: Sat, 1 Oct 2011 11:15:01 -0700
Message-ID: <CAEP_g=8uJnngfKJRGLLnd8U7M9aJTfOSUheB62-O7OX6Ud0DLw@mail.gmail.com>
References: <1317386643-3041-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:62981 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab1JASQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2011 14:16:28 -0400
Received: by vcbfk10 with SMTP id fk10so1950642vcb.19
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2011 11:16:27 -0700 (PDT)
In-Reply-To: <1317386643-3041-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2011 at 5:44 AM, Jiri Pirko <jpirko@redhat.com> wrote:
> This patch introduces new network device called team. It supposes to be
> very fast, simple, userspace-driven parallel to existing bonding device.
> Userspace library called libteam with couple of demo apps is available
> here:
> https://github.com/jpirko/libteam
> Note it's still in its dipers atm.
>
> team<->libteam use generic netlink for communication. That and rtnl
> suppose to be the only way to configure team device, no sysfs etc.
>
> In near future python binding for libteam will be introduced. Also
> daemon providing arpmon/miimon active-backup functionality will
> be introduced. All what's necessary is already implemented in kernel team
> driver.
>
> Plan is to support 8023ad in near future with it's logic mainly in
> userspace daemon as well.
>
> Please review, try, comment. All feedback would be much appreciated.
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Not to push my own agenda too much but you might want to take a look
at Open vSwitch.  It uses the same strategy of userspace directed
bonding and already supports active-backup, 802.3ad, and quite a few
other networking tools all controlled by userspace.

I know there's been a lot of talk and not a lot of action when it
comes to upstreaming but that's changing.  We're fixing up a few loose
ends in the userspace/kernel interface and then intend to propose a
patch fairly soon.

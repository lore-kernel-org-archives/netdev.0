From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH] net: add support for netdev notifier error injection
Date: Tue, 1 Dec 2015 08:48:30 +0900
Message-ID: <CAC5umyjONtF9r=Ox1-mMS-vzxp2j-fk+VX1wWWVvWvyOxWPbiQ@mail.gmail.com>
References: <1448714728-12729-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com, roopa@cumulusnetworks.com,
	dsa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:33620 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299AbbK3Xsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 18:48:31 -0500
In-Reply-To: <1448714728-12729-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-11-28 21:45 GMT+09:00 Nikolay Aleksandrov <razor@blackwall.org>:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> This module allows to insert errors in some of netdevice's notifier
> events. All network drivers use these notifiers to signal various events
> and to check if they are allowed, e.g. PRECHANGEMTU and CHANGEMTU
> afterwards. Until recently I had to run failure tests by injecting
> a custom module, but now this infrastructure makes it trivial to test
> these failure paths. Some of the recent bugs I fixed were found using
> this module.
> Here's an example:
>  $ cd /sys/kernel/debug/notifier-error-inject/netdev
>  $ echo -22 > actions/NETDEV_CHANGEMTU/error
>  $ ip link set eth0 mtu 1024
>  RTNETLINK answers: Invalid argument

This patch looks good to me.  It would be nice if you add tools like
tools/testing/selftests/cpu-hotplug/cpu-on-off-test.sh for this feature.

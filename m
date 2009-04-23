From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Thu, 23 Apr 2009 16:30:57 -0700
Message-ID: <m1hc0fuevi.fsf@fess.ebiederm.org>
References: <20090422055735.GA4334@night.netis.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, <netdev@vger.kernel.org>
To: "Alexander V. Lukyanov" <lav@netis.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:37150 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbZDWXbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 19:31:06 -0400
In-Reply-To: <20090422055735.GA4334@night.netis.ru> (Alexander V. Lukyanov's message of "Wed\, 22 Apr 2009 09\:57\:35 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Alexander V. Lukyanov" <lav@netis.ru> writes:

> Eventually I have an increased load average without apparent reason.
> When I reboot the server in such a case, I get infinitely repeating
> messages on the console:
>
> unregister_netdevice: waiting for eth0.2 to become free. Usage count = 4
>
> eth0.2 is a vlan interface, eth0 is 02:00.0 Ethernet controller: Realtek
> Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet
> controller (rev 01)

CC: netdev where someone might have a better clue.

Infinitely repeating unregister_netdevice messages means something
isn't releasing it's reference count to your network device.

There really isn't enough information in your email to figure out
what you were doing that, or what piece of code triggered this.

Eric

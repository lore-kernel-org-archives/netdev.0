From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: fix packets_per_slave showing
Date: Thu, 05 Dec 2013 05:03:35 -0800
Message-ID: <1386248615.30495.184.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386239818-7408-1-git-send-email-nikolay@redhat.com>
	 <20131205110843.GD23210@redhat.com>
	 <1386246835.30495.175.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131205124259.GE23210@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:52053 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756005Ab3LENDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 08:03:37 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so24471141pdj.40
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 05:03:36 -0800 (PST)
In-Reply-To: <20131205124259.GE23210@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 13:42 +0100, Veaceslav Falico wrote:
> .
> 
> Hrm? bond_check_params() isn't involved in sysfs at all :-/, it's called
> only via bonding_init(). And bond->params.packets_per_slave isn't read
> there at all, only assigned.
> 
> Or, given the naming confusions, I'm again missing something?

This is so confusing.

If the check was done properly, we could expose the value
in /sys/module/bonding/parameters/packets_per_slave

So that you can change the setting without reloading the module.

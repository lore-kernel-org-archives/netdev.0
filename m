From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: Re: [PATCH 3/5] net/netfilter/ipvs/ip_vs_ctl.c: drop argument range
 check just before the check for equality
Date: Sun, 20 Jul 2014 01:59:31 +0300
Message-ID: <CANZNk83yhnbw0c77UPnisaJr8AO8XtmUon78vEKGe=PBDrfWMw@mail.gmail.com>
References: <1405697638-23767-1-git-send-email-andrey.krieger.utkin@gmail.com>
	<alpine.LFD.2.11.1407182339160.2273@ja.home.ssi.bg>
	<CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, dcb314@hotmail.com,
	David Miller <davem@davemloft.net>, kadlec@blackhole.kfki.hu,
	Patrick McHardy <kaber@trash.net>, pablo@netfilter.org,
	Simon Horman <horms@verge.net.au>, wensong@linux-vs.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:52640 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbaGSW7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2014 18:59:32 -0400
In-Reply-To: <CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-19 0:06 GMT+03:00 Andrey Utkin <andrey.krieger.utkin@gmail.com>:
> What about static check at compilation time?
>
> #if (DAEMON_ARG_LEN > MAX_ARG_LEN) \
>  || (SERVICE_ARG_LEN > MAX_ARG_LEN) \
>  || (SVCDEST_ARG_LEN > MAX_ARG_LEN)
> #error MAX_ARG_LEN exceeded in set_arglen table
> #endif

This approach doesn't work, looks because sizeof() values are not
calculated at preprocessing stage.

-- 
Andrey Utkin

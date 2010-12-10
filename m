From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH] Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC v.2
Date: Fri, 10 Dec 2010 11:45:48 +0800
Message-ID: <4D01A26C.8060608@cn.fujitsu.com>
References: <4D011136.8030404@pavlinux.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pavel@pavlinux.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57791 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753877Ab0LJDrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 22:47:47 -0500
In-Reply-To: <4D011136.8030404@pavlinux.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Vasilyev wrote, at 12/10/2010 01:26 AM:
> Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC.
> IMHO convenient for testing.
> 
>+inflight_trigger_gc - INTEGER
>+	The maximal number of inflight sockets for force garbage collect.
>+
>+	Default: 16000

1) For lower payload and enough memory, it's not necessary to force garbage collection.
So set it to 0, disable gc.

2) Copy your patch to the mail, for other guys to review it.

-- 
Best Regards
-----
Shan Wei

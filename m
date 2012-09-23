From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] inet_diag: make config INET_DIAG bool
Date: Sat, 22 Sep 2012 21:36:34 -0700 (PDT)
Message-ID: <b133d67a-cb5f-4d46-b3d8-b1ac9448725e@tahiti.vyatta.com>
References: <1348372154-20663-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48960 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813Ab2IWEgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2012 00:36:44 -0400
In-Reply-To: <1348372154-20663-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> when inet_diag being compiled as module, inet_diag_handler_dump
> set netlink_dump_control.dump to inet_diag_dump,so if module
> inet_diag is unloaded,netlink will still try to call this function
> in netlink_dump. this will cause kernel panic.
>

Another way to handle this to just get rid of inet_diag_exit
so that module can be loaded but not unloaded.

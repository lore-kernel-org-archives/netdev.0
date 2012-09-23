From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] inet_diag: make config INET_DIAG bool
Date: Sun, 23 Sep 2012 15:40:27 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209231540180.15692@nerf07.vanv.qr>
References: <b133d67a-cb5f-4d46-b3d8-b1ac9448725e@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:46568 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753812Ab2IWNkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2012 09:40:32 -0400
In-Reply-To: <b133d67a-cb5f-4d46-b3d8-b1ac9448725e@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 2012-09-23 06:36, Stephen Hemminger wrote:

>> when inet_diag being compiled as module, inet_diag_handler_dump
>> set netlink_dump_control.dump to inet_diag_dump,so if module
>> inet_diag is unloaded,netlink will still try to call this function
>> in netlink_dump. this will cause kernel panic.
>
>Another way to handle this to just get rid of inet_diag_exit
>so that module can be loaded but not unloaded.

Why don't we unset netlink_dump_control.dump on exit?

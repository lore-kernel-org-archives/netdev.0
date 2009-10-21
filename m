From: =?windows-1251?Q?=C0=EB=E5=EA=F1=E0=ED=E4=F0_=C4=EE=F0=E8=F4?=
	<dorif@mail.ru>
Subject: Troubles with virtio network
Date: Wed, 21 Oct 2009 17:52:19 +0400
Message-ID: <E1N0bbv-0003zx-00.dorif-mail-ru@f248.mail.ru>
Reply-To: =?windows-1251?Q?=C0=EB=E5=EA=F1=E0=ED=E4=F0_=C4=EE=F0=E8=F4?=
	  <dorif@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback5.mail.ru ([94.100.176.59]:32810 "EHLO
	fallback5.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbZJUOKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 10:10:46 -0400
Received: from f248.mail.ru (f248.mail.ru [217.69.128.173])
	by fallback5.mail.ru (mPOP.Fallback_MX) with ESMTP id DD9BE19FFAC
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 17:52:40 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello! I compiled Linux kernel v 2.6.32-rc5 and got this warning:

WARNING: drivers/net/virtio_net.o(.data+0xa0): Section mismatch in reference from the variable virtio_net to the function .devexit.text:virtnet_remove()
The variable virtio_net references
the function __devexit virtnet_remove()
If the reference is valid then annotate the
variable with __exit* (see linux/init.h) or name the variable:
*driver, *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console, 

I hope it'll be corrected soon.

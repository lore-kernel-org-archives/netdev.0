From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: Section mismatch between 'copy_net_ns' and 'net_enable_timestamp
Date: Wed, 2 Jan 2008 16:16:12 +0200
Message-ID: <147a89290801020616g310fff86t6c8d34d32df3865a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:9914 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbYABOQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 09:16:14 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3162383fga.17
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2008 06:16:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
 I had git-cloned the net-2.6.25.git tree today;

 Then I ran "make menuconfig" and accepted the defaults without any change.
I want to build this tree with network namespace support.
I saw that in 2.6.25/net/core/net_namespace.c
we have some #ifdef CONFIG_NET_NS ; I did not CONFIG_NET_NS in "make
menuconfig".
So I added in net_namespace.c #define CONFIG_NET_NS, before the first
#ifdef CONFIG_NET_NS; then I ran make.

I saw the following warning:

WARNING: vmlinux.o(.text+0x1d47cd): Section mismatch: reference to .init.text:
(between 'copy_net_ns' and 'net_enable_timestamp')


Is there something wrong here causing this "Section mismatch"?
or did I do something wrong?

Regards,
Andy

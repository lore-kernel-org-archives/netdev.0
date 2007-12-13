From: Andrew Morton <akpm@linux-foundation.org>
Subject: net-2.6.25 section warnings
Date: Thu, 13 Dec 2007 02:07:22 -0800
Message-ID: <20071213020722.2790e023.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49446 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751492AbXLMKHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 05:07:25 -0500
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [207.189.120.55])
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id lBDA7Ngr008958
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 02:07:24 -0800
Received: from box (localhost [127.0.0.1])
	by imap1.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with SMTP id lBDA7Mi8025575
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 02:07:22 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: vmlinux.o(.init.text+0x1cfc4): Section mismatch: reference to .exit.text:tcpv6_exit (between 'inet6_init' and 'ac6_proc_init')
WARNING: vmlinux.o(.init.text+0x1cfc9): Section mismatch: reference to .exit.text:udplitev6_exit (between 'inet6_init' and 'ac6_proc_init')
WARNING: vmlinux.o(.init.text+0x1cfce): Section mismatch: reference to .exit.text:udpv6_exit (between 'inet6_init' and 'ac6_proc_init')
WARNING: vmlinux.o(.init.text+0x1cfdd): Section mismatch: reference to .exit.text:addrconf_cleanup (between 'inet6_init' and 'ac6_proc_init')
WARNING: vmlinux.o(.init.text+0x1d03c): Section mismatch: reference to .exit.text:rawv6_exit (between 'inet6_init' and 'ac6_proc_init')

http://userweb.kernel.org/~akpm/config-x.txt (x86_64)

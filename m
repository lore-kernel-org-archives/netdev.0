From: Michael Spiegle <mike@nauticaltech.com>
Subject: Re: [Bugme-new] [Bug 12201] New: long wait in call_usermodehelper()
 / queue_work() / wait_for_completion()
Date: Fri, 12 Dec 2008 11:47:16 -0800
Message-ID: <4942BFC4.2030203@nauticaltech.com>
References: <bug-12201-10286@http.bugzilla.kernel.org/>	 <20081211143758.510b51b6.akpm@linux-foundation.org> <ac3eb2510812111448s7c700199ia2e57834f91c02a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nauticaltech.com ([64.34.252.43]:34518 "EHLO nauticaltech.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbYLLTx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 14:53:58 -0500
In-Reply-To: <ac3eb2510812111448s7c700199ia2e57834f91c02a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If you replace /sbin/modprobe in the kernel module loader, does the
> delay go away:
>   echo /bin/true > /proc/sys/kernel/modprobe

Yes, that does reduce the delay significantly.  The timing of the 
socket() call went from about 1500000us to 430000us.  This points the 
finger at modprobe it seems?

Michael Spiegle
mike@nauticaltech.com

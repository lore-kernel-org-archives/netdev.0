From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10201] New: Yum update of Kernel broke sis900
	ethernet driver
Date: Tue, 11 Mar 2008 09:19:28 +0000
Message-ID: <20080311091928.GA5765@ff.dom.local>
References: <20080308155052.81cf3c8b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Dan McNaul <dmcnaul@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:63877 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbYCKJSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 05:18:01 -0400
Received: by mu-out-0910.google.com with SMTP id i10so7660273mue.5
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2008 02:18:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080308155052.81cf3c8b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09-03-2008 00:50, Andrew Morton wrote:
> On Sat,  8 Mar 2008 15:36:55 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=10201
...
>> Problem Description:  After reboot following YUM update to new kernel - SiS 900
>> PCI Fast Ethernet (driver sis900) can not ifconfig eth0.  Configuration fails
>> with  message "SIOCSIFFLAGS: Invalid argument".  System does boot. [...]

Dan, could you add to bugzilla report: dmesg, lspci -vvv, and 
cat /proc/interrupts after such a boot?

> Apparently a regression.  I seem to recall having seen reports of this
> before.
> 
> What could cuase SIOCSIFFLAGS to newly return -EINVAL?

request_irq()?

Regards,
Jarek P.

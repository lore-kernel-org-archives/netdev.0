From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 11649] New: Network don't work with SiS 900
   PCI Fast Ethernet. Mainly, I tried with DHCP interface. With exacly the
   same configurations network works on olders kernels and don't work on the
   newest
Date: Sat, 04 Oct 2008 19:57:07 +0200
Message-ID: <48E7AE73.8000202@gmail.com>
References: <bug-11649-10286@http.bugzilla.kernel.org/> <20081004033358.b3ea6500.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	mateusz.pastewski@gmail.com, Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:6998 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615AbYJDRwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 13:52:05 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1534422fkq.5
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2008 10:52:03 -0700 (PDT)
In-Reply-To: <20081004033358.b3ea6500.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote, On 10/04/2008 12:33 PM:

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 25 Sep 2008 17:35:20 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=11649
>>
>>            Summary: Network don't work with SiS 900 PCI Fast Ethernet.
>>                     Mainly, I tried with DHCP interface. With exacly the
>>                     same configurations network works on olders kernels and
>>                     don't work on the newest
>>            Product: Drivers
>>            Version: 2.5
>>      KernelVersion: 2.6.26.5
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: low
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: jgarzik@pobox.com
>>         ReportedBy: mateusz.pastewski@gmail.com
>>
>>
>> Latest working kernel version: 2.6.23.x
>> Earliest failing kernel version: 2.6.24.x


I guess it's because of this missing MAC address (as seen in your dmesg):

eth0: SiS 900 PCI Fast Ethernet at 0xd400, IRQ 10, 00:00:00:00:00:00

Jarek P.

PS: there was a change of kernel policy wrt. this.

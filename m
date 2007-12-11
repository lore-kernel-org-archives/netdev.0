From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at
 net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c
 (1055)
Date: Tue, 11 Dec 2007 16:04:27 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712111603250.21312@bizon.gios.gov.pl>
References: <bug-9543-10286@http.bugzilla.kernel.org/>
 <20071211034603.cbcc4762.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-802351681-1197385467=:21312"
Cc: bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:59586 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbXLKPFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 10:05:00 -0500
In-Reply-To: <20071211034603.cbcc4762.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-802351681-1197385467=:21312
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 11 Dec 2007, Andrew Morton wrote:

> On Tue, 11 Dec 2007 03:20:48 -0800 (PST) bugme-daemon@bugzilla.kernel.org=
 wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D9543
>>
>>            Summary: RTNL: assertion failed at net/ipv6/addrconf.c
>>                     (2164)/RTNL: assertion failed at net/ipv4/devinet.c
>>                     (1055)
>>            Product: Drivers
>>            Version: 2.5
>>      KernelVersion: 2.6.24-rc4-git7
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: jgarzik@pobox.com
>>         ReportedBy: olel@ans.pl
>>
>>
>> Most recent kernel where this bug did not occur: 2.6.23
>> Distribution: Gentoo
>>
>> Problem Description:
>> ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
>> RTNL: assertion failed at net/ipv6/addrconf.c (2164)
>> Pid: 9, comm: events/0 Not tainted 2.6.24-rc4-git7 #1
>>  [<78402cfb>] addrconf_notify+0x5b4/0x7b7
>>  [<7812203a>] finish_task_switch+0x0/0x8c
>>  [<781346ff>] worker_thread+0x0/0x85
>>  [<78438e23>] schedule+0x545/0x55f
>>  [<781408d1>] print_lock_contention_bug+0x11/0xd2
>>  [<783bfa72>] rt_run_flush+0x43/0x8b
>>  [<783bfa93>] rt_run_flush+0x64/0x8b
>>  [<7813ac54>] notifier_call_chain+0x2a/0x52
>>  [<7813ac9e>] raw_notifier_call_chain+0x17/0x1a
>>  [<783a3471>] netdev_state_change+0x18/0x29
>>  [<783ac6a9>] __linkwatch_run_queue+0x150/0x17e
>>  [<783ac6f4>] linkwatch_event+0x1d/0x22
>>  [<78133cdf>] run_workqueue+0xdb/0x1b6
>>  [<78133c8b>] run_workqueue+0x87/0x1b6
>>  [<783ac6d7>] linkwatch_event+0x0/0x22
>>  [<781346ff>] worker_thread+0x0/0x85
>>  [<78134778>] worker_thread+0x79/0x85
>>  [<781371ad>] autoremove_wake_function+0x0/0x35
>>  [<781370f6>] kthread+0x38/0x5e
>>  [<781370be>] kthread+0x0/0x5e
>>  [<78104baf>] kernel_thread_helper+0x7/0x10
>>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> RTNL: assertion failed at net/ipv6/addrconf.c (1610)
>
>
> Hopefully this is due to the bug you reported in bug #9542.
>
> Does this patch fix both issues?

Unfortunately not. I just updated bugzilla.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-802351681-1197385467=:21312--

From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10071] New: kernel hang in inet_init
Date: Mon, 25 Feb 2008 14:00:34 -0800
Message-ID: <20080225140034.5ef88935.akpm@linux-foundation.org>
References: <bug-10071-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, yannick.dirou@axetic.com,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: linux-acpi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:34964 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751470AbYBYWCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 17:02:03 -0500
In-Reply-To: <bug-10071-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Feb 2008 00:34:06 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10071
> 
>            Summary: kernel hang in inet_init
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.25 rc2 latest git
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: yannick.dirou@axetic.com
> 
> 
> Distribution:ubuntu hardy
> Hardware Environment:dell dimension 5150
> Problem Description:
> kernel hang mostly but boot slowly sometimes
> 
> Steps to reproduce:
> boot
> 
> when the computer manage to boot, inet_init last some time:
> [    1.725306] NET: Registered protocol family 2
> [    6.825384] IP route cache hash table entries: 32768 (order: 5, 131072
> bytes)
> [    6.825803] TCP established hash table entries: 131072 (order: 8, 1048576
> bytes)
> [    6.826691] TCP bind hash table entries: 65536 (order: 9, 2359296 bytes)
> [    6.836160] TCP: Hash tables configured (established 131072 bind 65536)
> [    6.836255] TCP reno registered
> [    7.081569] initcall 0xc03b8920: inet_init+0x0/0x3aa() returned 0.
> [    7.081569] initcall 0xc03b8920 ran for 5106 msecs: inet_init+0x0/0x3aa()
> 
> When booting with acpi=ht it works:
> [0.124668] Calling initcall 0xc03b8920: inet_init+0x0/0x3aa()
> [    0.124867] NET: Registered protocol family 2
> [    0.288067] IP route cache hash table entries: 32768 (order: 5, 131072
> bytes)
> [    0.288856] TCP established hash table entries: 131072 (order: 8, 1048576
> bytes)
> [    0.289739] TCP bind hash table entries: 65536 (order: 9, 2359296 bytes)
> [    0.299156] TCP: Hash tables configured (established 131072 bind 65536)
> [    0.299250] TCP reno registered
> Feb 23 09:10:28 tiyann kernel: [    0.162267] initcall 0xc03b8920:
> inet_init+0x0/0x3aa() returned 0.
> [    0.162383] initcall 0xc03b8920 ran for 33 msecs: inet_init+0x0/0x3aa()
> 
> there seem to be a weird interaction between acpi and inet_init
> 
> any hint on how to provide better information
> thanks
> 

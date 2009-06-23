From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13553] New: When NETCONSOLE is enabled in
 kernel, computer crashes after 120seconds (approx)
Date: Tue, 23 Jun 2009 14:07:43 -0700
Message-ID: <20090623140743.2b38ff6c.akpm@linux-foundation.org>
References: <bug-13553-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, hilld@binarystorm.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37989 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751887AbZFWVIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 17:08:02 -0400
In-Reply-To: <bug-13553-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 17 Jun 2009 01:55:54 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13553
> 
>            Summary: When NETCONSOLE is enabled in kernel, computer crashes
>                     after 120seconds (approx)
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.29.4, 2.6.30
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: hilld@binarystorm.net
>         Regression: No
> 
> 

> 00:00.0 Host bridge: Intel Corporation 440GX - 82443GX Host bridge
> 00:01.0 PCI bridge: Intel Corporation 440GX - 82443GX AGP bridge
> 00:07.0 ISA bridge: Intel Corporation 82371AB/EB/MB PIIX4 ISA (rev 02)
> 00:07.1 IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE (rev 01)
> 00:07.2 USB Controller: Intel Corporation 82371AB/EB/MB PIIX4 USB (rev 01)
> 00:07.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 02)
> 00:0b.0 SCSI storage controller: Adaptec AIC-7896U2/7897U2
> 00:0b.1 SCSI storage controller: Adaptec AIC-7896U2/7897U2
> 00:0d.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethernet Pro 100
> (rev 08)
> 00:12.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
> 01:00.0 VGA compatible controller: ATI Technologies Inc Rage 128 RL/VR AGP
> 
> ------- Comment #2 From David Hill 2009-06-17 02:55:56 (-) [reply] -------
> 
> With NETCONSOLE enabled, if I type:
> ethtool -s eth1 speed 100 duplex full autoneg on
> 
> the computer freezes with kernel 2.6.29.4 and 2.6.30...
> 
> I can reproduce it anytime you want.
> 

Interesting.  I wonder what the significance is of the 120 seconds.  I
see no such timers in e100.c.  Does the networking core have timers on
such intervals?


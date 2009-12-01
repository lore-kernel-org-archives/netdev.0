From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14702] New: via_rhine: Extremaly drop speed
 after days of work
Date: Tue, 1 Dec 2009 15:38:17 -0800
Message-ID: <20091201153817.b2936c8a.akpm@linux-foundation.org>
References: <bug-14702-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bbugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	rom_as@oscada.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59816 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754557AbZLAXjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 18:39:04 -0500
In-Reply-To: <bug-14702-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 27 Nov 2009 19:42:39 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14702
> 
>            Summary: via_rhine: Extremaly drop speed after days of work
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.29-2.6.30
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: rom_as@oscada.org
>         Regression: No
> 
> 
> Hardware is embeded device LP-8781 which have two identical VIA Rhine III
> cards:
> [root@localhost ~]# lspci
> 00:01.0 Host bridge: Advanced Micro Devices [AMD] CS5536 [Geode companion] Host
> Bridge (rev 33)
> 00:01.1 VGA compatible controller: Advanced Micro Devices [AMD] Geode LX Video
> 00:01.2 Entertainment encryption device: Advanced Micro Devices [AMD] Geode LX
> AES Security Block
> 00:0c.0 Ethernet controller: VIA Technologies, Inc. VT6105/VT6106S [Rhine-III]
> (rev 86)
> 00:0d.0 Ethernet controller: VIA Technologies, Inc. VT6105/VT6106S [Rhine-III]
> (rev 86)
> 00:0e.0 ISA bridge: Integrated Technology Express, Inc. IT8888F/G PCI to ISA
> Bridge with SMB [Golden Gate] (rev 03)
> 00:0f.0 ISA bridge: Advanced Micro Devices [AMD] CS5536 [Geode companion] ISA
> (rev 03)
> 00:0f.2 IDE interface: Advanced Micro Devices [AMD] CS5536 [Geode companion]
> IDE (rev 01)
> 00:0f.4 USB Controller: Advanced Micro Devices [AMD] CS5536 [Geode companion]
> OHC (rev 02)
> 00:0f.5 USB Controller: Advanced Micro Devices [AMD] CS5536 [Geode companion]
> EHC (rev 02)
> 
> via_rhine driver loaded correct and work some days fine but for next it drop
> speed to x10. No errors into logs and dmesg present, no one attribute for it
> reason detection.
> Problem is fixed only after call command service network restart and to next
> case time. If through interface going regular data then this problem repeated
> often.
> 
> Like problem is public here: https://bugzilla.redhat.com/show_bug.cgi?id=129304
> 
> And this problem had real fix only from use rhinefet driver from VIA. For build
> this module on last kernels created patch:
> http://wiki.oscada.org/Doc/ICPDAS/files?get=build_2.6.29.patch
> 


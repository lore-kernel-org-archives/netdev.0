From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Wed, 19 Aug 2009 23:25:08 +0200
Message-ID: <200908192325.08477.rene.mayrhofer@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at> <392fb48f0908190800j508456d6h9c520e82bc7f51e0@mail.gmail.com> <200908192307.22112.rene.mayrhofer@gibraltar.at>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:52919 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbZHSXTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 19:19:43 -0400
In-Reply-To: <200908192307.22112.rene.mayrhofer@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 19. August 2009 23:07:21 schrieb Rene Mayrhofer:
> In this state, rmmod sky2 / modprobe
> sky2 gives:
>
> [  718.502717] sky2 0000:01:00.0: unsupported chip type 0xff
> [  718.510517] sky2: probe of 0000:01:00.0 failed with error -95
> [  718.517900] sky2 0000:02:00.0: unsupported chip type 0xff
> [  718.524408] sky2: probe of 0000:02:00.0 failed with error -95
> [  718.531617] sky2 0000:03:00.0: unsupported chip type 0xff
> [  718.538104] sky2: probe of 0000:03:00.0 failed with error -95
> [  718.545344] sky2 0000:04:00.0: unsupported chip type 0xff
> [  718.551818] sky2: probe of 0000:04:00.0 failed with error -95

Just for the sake of completeness, I get this during bootup (i.e. before 
networking restart):

[    1.637607] sky2 driver version 1.24
[    1.637665] sky2 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 
16iled with error -95                3:00.0: unsupported chi[    1.637686] 
sky2 0000:01:00.0: setting latency timer to 64rror -95                
[    1.637718] sky2 0000:01:00.0: Yukon-2 EC chip revision 2 0xff                
[    1.637832] sky2 0000:01:00.0: irq 28 for MSI/MSI-X                           
[    1.638395] sky2 eth0: addr 00:90:0b:09:55:42                                 
[    1.638418] sky2 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17     
[    1.638431] sky2 0000:02:00.0: setting latency timer to 64                    
[    1.638458] sky2 0000:02:00.0: Yukon-2 EC chip revision 2                     
[    1.638567] sky2 0000:02:00.0: irq 29 for MSI/MSI-X                           
[    1.639117] sky2 eth1: addr 00:90:0b:09:55:43                                 
[    1.639140] sky2 0000:03:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18     
[    1.639152] sky2 0000:03:00.0: setting latency timer to 64                    
[    1.639180] sky2 0000:03:00.0: Yukon-2 EC chip revision 2
[    1.639289] sky2 0000:03:00.0: irq 30 for MSI/MSI-X
[    1.639869] sky2 eth2: addr 00:90:0b:09:55:44
[    1.639894] sky2 0000:04:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[    1.639906] sky2 0000:04:00.0: setting latency timer to 64
[    1.639934] sky2 0000:04:00.0: Yukon-2 EC chip revision 2
[    1.680096] sky2 0000:04:00.0: irq 31 for MSI/MSI-X
[    1.680786] sky2 eth3: addr 00:90:0b:09:55:45
[  106.751517] sky2 wan: enabling interface
[  107.404801] sky2 gibsrv: enabling interface
[  107.631583] sky2 dmz: enabling interface
[  107.869878] sky2 lan: enabling interface
[  109.225106] sky2 wan: Link is up at 1000 Mbps, full duplex, flow control 
both
[  109.232519] sky2 gibsrv: Link is up at 100 Mbps, full duplex, flow control 
both
[  109.983861] sky2 dmz: Link is up at 1000 Mbps, full duplex, flow control rx
[  110.453276] sky2 lan: Link is up at 1000 Mbps, full duplex, flow control rx

Then, at some point the interfaces get disabled (most probably by the 
networking restart):

[  224.652146] sky2 lan: disabling interface
[  224.684483] sky2 0000:04:00.0: PCI INT A disabled
[  224.700164] sky2 dmz: disabling interface
[  224.736502] sky2 0000:03:00.0: PCI INT A disabled
[  224.760219] sky2 gibsrv: disabling interface
[  224.812491] sky2 0000:02:00.0: PCI INT A disabled
[  224.832221] sky2 wan: disabling interface
[  224.904479] sky2 0000:01:00.0: PCI INT A disabled

best regards,
Rene


-- 
-------------------------------------------------
Gibraltar firewall       http://www.gibraltar.at/

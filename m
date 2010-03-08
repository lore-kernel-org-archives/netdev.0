From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: RE: bnx2x crash dump on high  network load
Date: Mon, 8 Mar 2010 11:02:20 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E6D79C1326A@GVW1118EXC.americas.hpqcorp.net>
References: <0199E0D51A61344794750DC57738F58E6D79C12E3E@GVW1118EXC.americas.hpqcorp.net>
 <BD3F7F1EFBA6D54DB056C4FFA451400803A1F8F2F7@SJEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: eliezert <eliezert@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:32806 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753510Ab0CHLEA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 06:04:00 -0500
In-Reply-To: <BD3F7F1EFBA6D54DB056C4FFA451400803A1F8F2F7@SJEXCHCCR01.corp.ad.broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have this option set in my /etc/modprobe.conf.local. The problem must be something else.

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Eilon Greenstein
> Sent: 05 March 2010 17:32
> To: Fischer, Anna
> Cc: eliezert; Michael Chan; netdev@vger.kernel.org
> Subject: RE: bnx2x crash dump on high network load
> 
> Hi Anna,
> 
> On this kernel, enabling bridging (like you do on virtualization) does
> not turn off LRO automatically. Please try to load the bnx2x with
> disable_tpa=1 (TPA is the HW based LRO feature).
> 
> Regards,
> Eilon
> 
> -----Original Message-----
> From: Fischer, Anna [mailto:anna.fischer@hp.com]
> Sent: Friday, March 05, 2010 7:08 PM
> To: netdev@vger.kernel.org
> Cc: eliezert; Eilon Greenstein; Michael Chan
> Subject: bnx2x crash dump on high network load
> 
> I am seeing driver crashes with a bnx2x version 1.50.16. I have attached
> two crash dumps that I have captured.
> 
> I run Linux with the following kernel:
> 
> # uname -a
> Linux sup-prj-441106 2.6.16.60-0.54.5-debug #1 SMP Fri Sep 4 01:28:03
> UTC 2009 x86_64 x86_64 x86_64 GNU/Linux
> 
> I am seeing these driver crashes when I run virtual machines (VMware
> Server) and those VMs do high bandwidth network I/O, so there are a lot
> of packets going through the NIC.
> 
> Can you give me any hints for what the problem here could be?
> 
> Thanks,
> Anna
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

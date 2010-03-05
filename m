From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: RE: bnx2x crash dump on high  network load
Date: Fri, 5 Mar 2010 09:31:36 -0800
Message-ID: <BD3F7F1EFBA6D54DB056C4FFA451400803A1F8F2F7@SJEXCHCCR01.corp.ad.broadcom.com>
References: <0199E0D51A61344794750DC57738F58E6D79C12E3E@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: eliezert <eliezert@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1261 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754648Ab0CERbv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 12:31:51 -0500
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D79C12E3E@GVW1118EXC.americas.hpqcorp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anna,

On this kernel, enabling bridging (like you do on virtualization) does not turn off LRO automatically. Please try to load the bnx2x with disable_tpa=1 (TPA is the HW based LRO feature).

Regards,
Eilon

-----Original Message-----
From: Fischer, Anna [mailto:anna.fischer@hp.com] 
Sent: Friday, March 05, 2010 7:08 PM
To: netdev@vger.kernel.org
Cc: eliezert; Eilon Greenstein; Michael Chan
Subject: bnx2x crash dump on high network load

I am seeing driver crashes with a bnx2x version 1.50.16. I have attached two crash dumps that I have captured.

I run Linux with the following kernel:

# uname -a
Linux sup-prj-441106 2.6.16.60-0.54.5-debug #1 SMP Fri Sep 4 01:28:03 UTC 2009 x86_64 x86_64 x86_64 GNU/Linux

I am seeing these driver crashes when I run virtual machines (VMware Server) and those VMs do high bandwidth network I/O, so there are a lot of packets going through the NIC. 

Can you give me any hints for what the problem here could be?

Thanks,
Anna


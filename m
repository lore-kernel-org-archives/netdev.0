From: "R. Weinedel" <r.weinedel@yahoo.de>
Subject: Re: vlan performance issue on outgoing traffic (solved)
Date: Wed, 28 Apr 2010 23:13:08 +0200
Message-ID: <4BD8A4E4.1050707@yahoo.de>
References: <4BD4C037.2070003@yahoo.de> <alpine.WNT.2.00.1004271110300.4368@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp116.plus.mail.re1.yahoo.com ([69.147.102.79]:27690 "HELO
	smtp116.plus.mail.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755683Ab0D1VNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 17:13:23 -0400
In-Reply-To: <alpine.WNT.2.00.1004271110300.4368@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I made some further test with kernel 2.6.26 and I recognized that my cpu
is really very busy (90-100 % sw-irq's) during offloads.

After that I build and install a 2.6.33 kernel and the problem seems to
be solved. Now I got 946 Mbit/s offload (iperf) !.

Ralf Weinedel


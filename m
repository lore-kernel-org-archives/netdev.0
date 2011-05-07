From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: For the netdev list
Date: Sat, 7 May 2011 20:26:32 +0200
Message-ID: <20110507182632.GA20492@electric-eye.fr.zoreil.com>
References: <14130884-5927-4B8D-A52E-56C245D8225B@virtualcomputer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tom Goetz <tom.goetz@virtualcomputer.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33241 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab1EGSfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 14:35:55 -0400
Content-Disposition: inline
In-Reply-To: <14130884-5927-4B8D-A52E-56C245D8225B@virtualcomputer.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Goetz <tom.goetz@virtualcomputer.com> :
> We recently obtained a new a Lenovo Edge 0578-CTO. The r8169 driver causes
> instability in the system on this machine. The problem is that in
> rtl8169_rx_interrupt (status & 0x00001FFF) returns values less than four

This is unexpected. :o(

[...]
> For a work around we've added a patch to drop packets when we see this
> condition. I have attached lspci -vvv for this device and a patch for the
> work around we're using.

Thank you for debugging.

Can you grep for the XID of the device in the kernel's dmesg and specify
a bit of context for the problem (MTU ? features enabled through ethtool ?
kernel version ?) ?

-- 
Ueimor


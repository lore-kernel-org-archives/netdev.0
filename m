From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 08/12] r8152: support TSO
Date: Tue, 4 Mar 2014 21:11:48 +0800
Message-ID: <CF9EF717568D49DB858D5363B1099FC0@realtek.com.tw>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com> <1393934464-23675-9-git-send-email-hayeswang@realtek.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CFFE0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: 'David Laight' <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:58673 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757168AbaCDNL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 08:11:56 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CFFE0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 David Laight [mailto:David.Laight@ACULAB.COM] 
> Sent: Tuesday, March 04, 2014 8:12 PM
> To: 'Hayes Wang'; netdev@vger.kernel.org
> Cc: nic_swsd@realtek.com; linux-kernel@vger.kernel.org; 
> linux-usb@vger.kernel.org
> Subject: RE: [PATCH net-next 08/12] r8152: support TSO
> 
> From: Hayes Wang
> > Support scatter gather and TSO.
> > 
> > Adjust the tx checksum function and set the max gso size to fix the
> > size of the tx aggregation buffer.
> 
> There is little point supporting TSO unless the usb host controller
> supports arbitrary aligned scatter-gather.
> All you do is require that a large skb be allocated (that may well
> fail), and add it another data copy.

I think I have done it. For also working for EHCI usb host controller,
I allocate 16 KB continuous buffer and copy the fragmented packets to
it and bulk out the buffer.
 
Best Regards,
Hayes

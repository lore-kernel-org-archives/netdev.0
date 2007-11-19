From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH 2/2] virtio: free transmit skbs when notified, not on next xmit.
Date: Mon, 19 Nov 2007 11:31:08 +0100
Message-ID: <200711191131.08630.borntraeger@de.ibm.com>
References: <200711191120.15596.rusty@rustcorp.com.au> <200711191125.45065.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: lguest <lguest@ozlabs.org>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	Anthony Liguori <aliguori@us.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:44509 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbXKSKbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 05:31:12 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id lAJAVBji035406
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 10:31:11 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAJAVAYZ2785300
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 11:31:10 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJAV9V7019290
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 11:31:10 +0100
In-Reply-To: <200711191125.45065.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 19. November 2007 schrieb Rusty Russell:
> This fixes a potential dangling xmit problem.
> 
> We also suppress refill interrupts until we need them.
> (Anthony and I have been working on performance recently, so this
> is a WIP).
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks Rusty,
that was the 2nd next item on my todo list :-)

Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>

From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: Inconsistent lock  state and possible irq lock inversion
	dependency detected in ax25.ko
Date: Wed, 5 Dec 2007 00:45:45 +0000
Message-ID: <20071205004545.GA2957@linux-mips.org>
References: <20071003185413.GA16242@martell.zuzino.mipt.ru> <4744AD8B.2000908@ccr.jussieu.fr> <4752ED3D.2060204@ccr.jussieu.fr> <47532B60.8030205@o2.pl> <4755D42C.9000107@ccr.jussieu.fr> <4755E01B.9010307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Pidoux <pidoux@ccr.jussieu.fr>,
	Jarek Poplawski <jarkao2@o2.pl>, davem@davemloft.net,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:56086 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbXLEAty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 19:49:54 -0500
Received: from localhost.localdomain ([127.0.0.1]:12204 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20033628AbXLEAtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 00:49:52 +0000
Content-Disposition: inline
In-Reply-To: <4755E01B.9010307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 12:17:47AM +0100, Jarek Poplawski wrote:

> Bernard, I think you've forgotten at least about some distinct
> changelog and signed-off-by?
> 
> Jarek P.
> ---
> 
> ax25_subr.c part:
> Acked-by: Jarek Poplawski <jarkao2@gmail.com>

The fix for the deadlock due to taking rose_node_list_lock twice:

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Part of Bernard's patch is undoing d85838c55d836c33077344fab424f200f2827d84,
this one should probably reverted separately.

  Ralf

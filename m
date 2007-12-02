From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: Re: Inconsistent lock  state and possible irq lock inversion dependency
 detected in ax25.ko
Date: Sun, 02 Dec 2007 18:37:01 +0100
Message-ID: <4752ED3D.2060204@ccr.jussieu.fr>
References: <20071003185413.GA16242@martell.zuzino.mipt.ru> <4744AD8B.2000908@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090106070906020009030805"
Cc: ralf@linux-mips.org, davem@davemloft.net, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix2-g20.free.fr ([212.27.60.43]:43887 "EHLO
	postfix2-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbXLBRjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 12:39:08 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix2-g20.free.fr (Postfix) with ESMTP id 6E9FC1FD7862
	for <netdev@vger.kernel.org>; Sun,  2 Dec 2007 16:38:15 +0100 (CET)
In-Reply-To: <4744AD8B.2000908@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090106070906020009030805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Many thanks for your patch for ~/net/ax25/ax25_subr.c

Introduction of local_bh_disable() ... local_bh_enable()

cured the inconsistent lock state related to AX25 connect timeout.

I have now a stable monoprocessor system running AX25 and ROSE network 
packet switching application FPAC, whether kernel is compiled with or 
without hack option.

There is no more problem during normal operations.

This was achieved, thanks to your AX25 patch and the patch from Alexey 
Dobriyan for rose module.

I also patched rose module in order to get packet routing more 
efficient, taking into account the "restarted" flag that is raised when 
a neighbour node is already connected.

To summarize the present situation on my Linux machine, I built a patch 
against kernel 2.6.23.9.

I would appreciate if you could make it included into a next kernel release.

Many thanks and best regards,

Bernard Pidoux
F6BVP



--------------090106070906020009030805
Content-Type: application/x-compressed-tar;
 name="rose-patch-2.6.23.9.tgz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="rose-patch-2.6.23.9.tgz"

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
RhlllNHPSf8BhGklxwAoAAA=
--------------090106070906020009030805--

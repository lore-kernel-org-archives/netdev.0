From: "J. Christopher Pereira" <kripper@imatronix.cl>
Subject: RE: r8169: link up, link down
Date: Wed, 18 Jul 2012 14:23:04 -0400
Message-ID: <038001cd6512$613125c0$23937140$@cl>
References: <02b401cd64f9$115acc90$341065b0$@cl> <20120718173909.GA12524@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Francois Romieu'" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from abufalia.dnsforhost.com ([67.220.212.159]:51774 "EHLO
	abufalia.dnsforhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381Ab2GRSXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:23:13 -0400
In-Reply-To: <20120718173909.GA12524@electric-eye.fr.zoreil.com>
Content-Language: es
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois:

Thanks for answering.

> If it's an XID 98000000 - i.e. old new hardware - you may try to remove
the device then rescan the PCI bus through sysfs.

dmesg says "eth0: RTL8110s at 0xffffc2000067ec00, 00:4f:4a:10:1e:cf, XID
04000000 IRQ 16".

> Building a modern kernel is strongly suggested if the hardware includes a
recent 816x chipset.

Is there any particular patch I could apply and just recompile the driver?
My hope was to first receive feedback and identify some probably related
known bug, in order to avoid searching for a solution by trial and error or
by updating the whole environment.

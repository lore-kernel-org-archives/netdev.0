From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: link up, link down
Date: Wed, 18 Jul 2012 19:39:09 +0200
Message-ID: <20120718173909.GA12524@electric-eye.fr.zoreil.com>
References: <02b401cd64f9$115acc90$341065b0$@cl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "J. Christopher Pereira" <kripper@imatronix.cl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52281 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab2GRRvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 13:51:52 -0400
Content-Disposition: inline
In-Reply-To: <02b401cd64f9$115acc90$341065b0$@cl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

J. Christopher Pereira <kripper@imatronix.cl> :
[...]
> Is there any solution or workarround?

If it's an XID 98000000 - i.e. old new hardware - you may try to remove the
device then rescan the PCI bus through sysfs.

Building a modern kernel is strongly suggested if the hardware includes
a recent 816x chipset.

-- 
Ueimor

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: WARNING: at kernel/softirq.c:159 _local_bh_enable_ip+0x35/0x71()
Date: Tue, 21 Feb 2012 10:56:10 +0100
Message-ID: <20120221095610.GA24089@electric-eye.fr.zoreil.com>
References: <6280313.121891329808960531.JavaMail.weblogic@epml01>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jongman Heo <jongman.heo@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50553 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029Ab2BUKI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 05:08:58 -0500
Content-Disposition: inline
In-Reply-To: <6280313.121891329808960531.JavaMail.weblogic@epml01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jongman Heo <jongman.heo@samsung.com> :
[...]
> Host : windows 7 32bit
> VMWare Guest : Fedora 16, with latest linus git kernel (3.3.0-rc4+). 
>                         vmxnet3 ethernet driver, running NFS server

This is a 32bit HIGHMEM kernel, right ?

> Following warning triggered with my VMware Linux guest, when NFS connection is requested from outside.

I'd try reverting 39d4a96fd7d2926e46151adbd18b810aeeea8ec0.

-- 
Ueimor

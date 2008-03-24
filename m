From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek source
Date: Mon, 24 Mar 2008 14:18:24 +0100
Message-ID: <20080324131824.GA18032@electric-eye.fr.zoreil.com>
References: <20080323230045.GA16510@vsuchard.aplis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlastislav SUCHARDA <vsucharda@aplis.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47669 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754668AbYCXNjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 09:39:10 -0400
Content-Disposition: inline
In-Reply-To: <20080323230045.GA16510@vsuchard.aplis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlastislav SUCHARDA <vsucharda@aplis.cz> :
[...]
> how can I get the source for this specific version of module:
> 
> filename:       /lib/modules/2.6.20-1.2962.fc6/kernel/drivers/net/r8169.ko

This is a distribution related question so it would not hurt to be asked
on some Fedora mailing list.

Summon your favorite search engine for kernel-2.6.20-1.2962.fc6.src.rpm
and try something like rpm2cpio kernel-2.6.20-1.2962.fc6.src.rpm | cpio -id
in a dedicated directory.

[...]
> That is only version which works well with my pci:v000010ECd00008168sv on
> my laptop, I need to port on Centos 5.1 latest kernel 2.6.18.
> My problem is that Rx (copying in) is super, Tx (copying out) is freezing.

Asus laptop ?

I would welcome the complete dmesg of your more recent tested kernel as
well as a complete lspci -vvxnn.

-- 
Ueimor

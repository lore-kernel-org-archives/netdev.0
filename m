From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 22:26:17 +0200
Message-ID: <20080616202617.GA7402@electric-eye.fr.zoreil.com>
References: <20080616193501.M64730@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux.nics@intel.com
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42397 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754593AbYFPUzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 16:55:48 -0400
Content-Disposition: inline
In-Reply-To: <20080616193501.M64730@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko <denys@visp.net.lb> :
[...]
> I moved from PCI Realtek 8169 to onboard PCI-Express e1000e, and situation
> become worse. Strange ? Yes.

Could it be that the r8169 and the e1000e driver do not use the same locking
tricks at all ?

-- 
Ueimor

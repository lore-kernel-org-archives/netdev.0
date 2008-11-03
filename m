From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Broken "SMC91x: delete unused local variable "lp""
Date: Mon, 3 Nov 2008 16:35:54 +0300
Message-ID: <20081103133554.GA3325@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vapier@gentoo.org, netdev@vger.kernel.org
To: jgarzik@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:9204 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162AbYKCNcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 08:32:41 -0500
Received: by nf-out-0910.google.com with SMTP id d3so962758nfc.21
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 05:32:38 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff, please, revert 51ac3beffd4afaea4350526cf01fe74aaff25eff aka
"SMC91x: delete unused local variable "lp""

"lp" is used via ATTRIB_SIZE->SMC_IO_SHIFT, on arm-am200epdkit defconfig for example:

drivers/net/smc91x.c: In function 'smc_request_attrib':
drivers/net/smc91x.c:2067: error: 'lp' undeclared (first use in this function)
drivers/net/smc91x.c:2067: error: (Each undeclared identifier is reported only once
drivers/net/smc91x.c:2067: error: for each function it appears in.)
drivers/net/smc91x.c: In function 'smc_release_attrib':
drivers/net/smc91x.c:2079: error: 'lp' undeclared (first use in this function)

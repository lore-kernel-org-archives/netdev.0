From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Sun, 29 Jan 2017 22:02:27 +0100
Message-ID: <20170129210227.GB30336@localhost.localdomain>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153536.GD2223@localhost.localdomain>
 <BL2PR07MB2306088B2179138BB4557FE58D480@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36547 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbdA2VCj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 16:02:39 -0500
Received: by mail-wm0-f67.google.com with SMTP id r18so1513851wmd.3
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 13:02:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB2306088B2179138BB4557FE58D480@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 29, 2017 at 05:30:51PM +0000, Mintz, Yuval wrote:
> That's part of the driver structuring - qed is responsible for accessing HW
> so it implements api functions for accessing PTP-related configuration,
> while qede is responsible for the network interface and thus is the one to
> register the clock and implements its API.

But there is only one 'qed', and so the separation is just busy work.
Or is there another kind of qed that I missed?

BTW, gotta love the help in your kconfig:

config QED
	tristate "QLogic QED 25/40/100Gb core driver"
	depends on PCI
	select ZLIB_INFLATE
	---help---
	  This enables the support for ...

config QEDE
	tristate "QLogic QED 25/40/100Gb Ethernet NIC"
	depends on QED
	---help---
	  This enables the support for ...

Thanks,
Richard

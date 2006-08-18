From: "Jesse Huang" <jesse@icplus.com.tw>
Subject: Re: [PATCH 1/6] IP100A, add end of pci id table
Date: Fri, 18 Aug 2006 13:52:26 +0800
Message-ID: <02d101c6c28a$7c19d160$4964a8c0@icplus.com.tw>
References: <1155841247.4532.6.camel@localhost.localdomain> <44E480FA.70806@pobox.com>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr3.hinet.net ([168.95.4.103]:49657 "EHLO msr3.hinet.net")
	by vger.kernel.org with ESMTP id S964841AbWHRFwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 01:52:44 -0400
To: "Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff:

    Sorry for that. I will remove those. Am I need to resent all of those
patch or send all in one patch?

Jesse Huang.

----- Original Message ----- 
From: "Jeff Garzik" <jgarzik@pobox.com>
To: "Jesse Huang" <jesse@icplus.com.tw>
Cc: <linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>;
<akpm@osdl.org>
Sent: Thursday, August 17, 2006 10:45 PM
Subject: Re: [PATCH 1/6] IP100A, add end of pci id table


Jesse Huang wrote:
> @@ -212,7 +212,7 @@ static const struct pci_device_id sundan
>  { 0x1186, 0x1002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4 },
>  { 0x13F0, 0x0201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5 },
>  { 0x13F0, 0x0200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6 },
> - { }
> + { 0,}
>  };
>  MODULE_DEVICE_TABLE(pci, sundance_pci_tbl);
>
> @@ -231,7 +231,7 @@ static const struct pci_id_info pci_id_t
>  {"D-Link DL10050-based FAST Ethernet Adapter"},
>  {"Sundance Technology Alta"},
>  {"IC Plus Corporation IP100A FAST Ethernet Adapter"},
> - { } /* terminate list. */
> + { NULL,} /* terminate list. */

NAK.

An empty array element "{ }" implies NULL.  It is the kernel standard to
prefer "{ }" over an explicit initialization.  Looks cleaner.

Jeff



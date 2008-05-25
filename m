From: Marin Mitov <mitov@issp.bas.bg>
Subject: DECLARE_PCI_UNMAP_{ADDR,LEN} question
Date: Sun, 25 May 2008 07:48:38 +0300
Message-ID: <200805250748.38163.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.issp.bas.bg ([195.96.236.10]:51123 "EHLO mail.issp.bas.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbYEYEsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 May 2008 00:48:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

In Documentation/DMA-mapping.txt is written:

NOTE: DO NOT put a semicolon at the end of the 
DECLARE_PCI_UNMAP_{ADDR,LEN}() macro.

While the output of 
grep DECLARE_PCI_UNMAP_  drivers/net/* 
contains lines with and without semicolon:
drivers/net/acenic.h:   DECLARE_PCI_UNMAP_ADDR(mapping)
drivers/net/acenic.h:   DECLARE_PCI_UNMAP_ADDR(mapping)
drivers/net/acenic.h:   DECLARE_PCI_UNMAP_LEN(maplen)
drivers/net/bnx2.h:     DECLARE_PCI_UNMAP_ADDR(mapping)
drivers/net/bnx2.h:     DECLARE_PCI_UNMAP_ADDR(mapping)
drivers/net/bnx2x.h:    DECLARE_PCI_UNMAP_ADDR(mapping)
drivers/net/qla3xxx.h:   DECLARE_PCI_UNMAP_ADDR(mapaddr);
drivers/net/qla3xxx.h:   DECLARE_PCI_UNMAP_LEN(maplen);
drivers/net/qla3xxx.h:   DECLARE_PCI_UNMAP_ADDR(mapaddr);
drivers/net/qla3xxx.h:   DECLARE_PCI_UNMAP_LEN(maplen);
drivers/net/skge.h:     DECLARE_PCI_UNMAP_ADDR(mapaddr);
drivers/net/skge.h:     DECLARE_PCI_UNMAP_LEN(maplen);
drivers/net/sky2.h:     DECLARE_PCI_UNMAP_ADDR(mapaddr);
drivers/net/sky2.h:     DECLARE_PCI_UNMAP_ADDR(maplen);
drivers/net/sky2.h:     DECLARE_PCI_UNMAP_ADDR(data_size);
drivers/net/tg3.h:      DECLARE_PCI_UNMAP_ADDR(mapping)
drivers/net/tg3.h:      DECLARE_PCI_UNMAP_ADDR(mapping)

My question is: 
Why one should NOT put semicolon at the end of the macro?
If it is _really_ important, should it be removed/patched?

Thank you for your answers.

Regards

Marin Mitov


From: Marin Mitov <mitov@issp.bas.bg>
Subject: pci_set_consistent_dma_mask() question
Date: Sun, 25 May 2008 08:43:47 +0300
Message-ID: <200805250843.47179.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755214AbYEYFnu@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

In the file: Documentation/DMA-mapping.txt is written:

pci_set_consistent_dma_mask() will always be able to set the same or a
smaller mask as pci_set_dma_mask(). However for the rare case that a
device driver only uses consistent allocations, one would have to
check the return value from pci_set_consistent_dma_mask().

grep-ing drivers/net/* shows that in many drivers 
the return value of pci_set_consistent_dma_mask() is checked
in the path where pci_set_dma_mask() was already successfull.
Sure, this is during driver's initiallysation, so it is not time critical.

My question: Is it worth to remove the unnecessary checks?
I could prepare patches if you find it worthfull.

Best regards.

Marin Mitov

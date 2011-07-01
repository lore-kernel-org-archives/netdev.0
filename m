From: <Sathya.Perla@Emulex.Com>
Subject: coding style question on indentation
Date: Fri, 1 Jul 2011 04:20:30 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F63F87EF145E@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:30386 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754793Ab1GALUu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 07:20:50 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Which of the following styling is preferable when a function invocation spans more than one line:

a) Aligning the next line with the first argument by inserting a few spaces after the tabs - as in:

	dma_unmap_page(&adapter->pdev->dev,
			   dma_unmap_addr(rx_page_info, bus),
			   adapter->big_page_size, DMA_FROM_DEVICE);

Documentation/CodingStyle says "spaces are never used for indentation", but I see
scripts/Lindent inserting spaces after tabs for alignment.

OR

b) Just using tabs without needing to align as above:

	dma_unmap_page(&adapter->pdev->dev,
			dma_unmap_addr(rx_page_info, bus),
			adapter->big_page_size, DMA_FROM_DEVICE);


thanks,
-Sathya

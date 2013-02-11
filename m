From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: atl1c DMA-API mapping errors in 3.8-rc6+
Date: Mon, 11 Feb 2013 16:10:26 +0000
Message-ID: <157393863283F442885425D2C4542856489C67E4@nasanexd02f.na.qualcomm.com>
References: <20130211130812.GA21501@hansolo.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	nic-devel <nic-devel@qca.qualcomm.com>
To: Josh Boyer <jwboyer@redhat.com>, Jay Cliburn <jcliburn@gmail.com>,
	"Chris Snook" <chris.snook@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:42893 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757725Ab3BKQK2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 11:10:28 -0500
In-Reply-To: <20130211130812.GA21501@hansolo.jdub.homelinux.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> We've had two different reports[1] in Fedora of users hitting DMA-API errors
> with the atl1c driver on 3.8-rc6+.  The errors are from different locations, but
> the problem is the same.  Essentially, the driver isn't doing any form of
> pci_dma_mapping_error checking after calling pci_map_single.
> 


Josh, I will add pci_dma_mapping_error checking, thanks for your help !


BR.
Xiong

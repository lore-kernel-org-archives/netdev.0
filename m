From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/3] enic: check dma_mapping_error
Date: Mon, 5 Jan 2015 17:28:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC0D6C@AcuExch.aculab.com>
References: <1419416978-1008-1-git-send-email-_govind@gmx.com>
 <1419416978-1008-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>
To: 'Govindarajulu Varadarajan' <_govind@gmx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sassmann@redhat.com" <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:50805 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbbAERk2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 12:40:28 -0500
In-Reply-To: <1419416978-1008-3-git-send-email-_govind@gmx.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch checks for pci_dma_mapping_error() after dma mapping the data.
> If the dma mapping fails we remove the previously queued frags and return
> NETDEV_TX_OK.

This patch contains a lot of whitespace changes that make it
very difficult to review.

Split the patch.

	David

From: <jon_zhou@agilent.com>
Subject: RE: can we reuse an skb
Date: Fri, 19 Jun 2009 14:51:45 +0800
Message-ID: <60230E21F17E384C9BF0B9C98D9E3FDC048963D6@sgp-sg-mb02.sgp.agilent.com>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <radhamohan_ch@yahoo.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aglsgpbs03.sgp.agilent.com ([192.25.82.35]:60772 "EHLO
	aglsgpbs03.sgp.agilent.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752467AbZFSHFP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2009 03:05:15 -0400
Content-class: urn:content-classes:message
In-Reply-To: <962874.62146.qm@web94813.mail.in2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am also thinking about this...

i.e.pcnet32.c
seems the skb will be claimed to be unuseful(mark some bits) in the device driver, than it will be recycled in the softirq handler,

that means unable to reuse it, unless modidy the driver.

Regards,
zhou rui

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Radha Mohan
Sent: Friday, June 19, 2009 2:47 PM
To: netdev@vger.kernel.org
Subject: can we reuse an skb


Hi,

For an ethernet driver, we need to allocate some pool of SKBs for receiving packets. Is there any way we can reuse the same SKBs without the need to re-allocate in atomic every time one has been used up for netif_rx(). 

Any pointers will be helpful.

-- Mohan


      ICC World Twenty20 England &#39;09 exclusively on YAHOO! CRICKET http://cricket.yahoo.com

--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html



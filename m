From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 v2] can: add support for CAN interface cards
 based on the PLX90xx PCI bridge
Date: Wed, 03 Feb 2010 18:39:12 -0800 (PST)
Message-ID: <20100203.183912.11580106.davem@davemloft.net>
References: <1265053364-24099-1-git-send-email-chebl@star.inp.nsk.su>
	<4B673E19.40904@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: P.B.Cheblakov@inp.nsk.su, netdev@vger.kernel.org,
	Socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36337
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750725Ab0BDCi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 21:38:59 -0500
In-Reply-To: <4B673E19.40904@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Mon, 01 Feb 2010 21:48:25 +0100

> Pavel B. Cheblakov wrote:
>> From: Pavel Cheblakov <P.B.Cheblakov@inp.nsk.su>
>> 
>> This driver is for CAN interface cards based on the PLX90xx PCI bridge.
>> Driver supports now:
>>  - Adlink PCI-7841/cPCI-7841 card (http://www.adlinktech.com/)
>>  - Adlink PCI-7841/cPCI-7841 SE card
>>  - Marathon CAN-bus-PCI card (http://www.marathon.ru/)
>>  - TEWS TECHNOLOGIES TPMC810 card (http://www.tews.com/)
>> 
>> Changes since v1:
>>  - Added some defines for static inline int plx_pci_check_sja1000(...)
>>  - static struct pci_device_id plx_pci_tbl[] replaced by
>>    static DEFINE_PCI_DEVICE_TABLE(plx_pci_tbl)
>>  - Typo fixed
>> 
>> Signed-off-by: Pavel Cheblakov <P.B.Cheblakov@inp.nsk.su>
>> Acked-by: Wolfgang Grandegger <wg@grandegger.com>
> 
> Looks good now. The interface seems now generic enough to support other
> PLX09xx based CAN cards as well.
> 
> Thanks for your contribution.

Applied, thanks everyone.

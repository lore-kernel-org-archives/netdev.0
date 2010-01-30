From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next-2.6] can: add support for CAN interface cards
 based	on the PLX90xx PCI bridge
Date: Sat, 30 Jan 2010 20:04:14 +0100
Message-ID: <4B6482AE.4060402@grandegger.com>
References: <1264758309-1632-1-git-send-email-chebl@star.inp.nsk.su> <4B647F16.9000105@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: "Pavel B. Cheblakov" <P.B.Cheblakov@inp.nsk.su>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:41004 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734Ab0A3TFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 14:05:25 -0500
In-Reply-To: <4B647F16.9000105@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Hi Pavel,
> 
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
>> Signed-off-by: Pavel Cheblakov <P.B.Cheblakov@inp.nsk.su>
> 
> We already discussed this patch on the Socketcan mailing list and it's
> OK from my point of view. Please fix the minor issues reported by Daniel
> Baluta. To v2 of the patch you can then add directly my
> "Acked-by: Wolfgang Grandegger <wg@grandegger.com>"

I just realized one more issue. The driver creates section mismatches.
Please use "static DEFINE_PCI_DEVICE_TABLE(plx_pci_tbl)" as, for
example, the ems_pci driver does.

Wolfgang.

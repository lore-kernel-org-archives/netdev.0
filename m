From: Sharma Bhupesh-B45370 <B45370@freescale.com>
Subject: Query: Regarding 8211E Phy module support in drivers/net/phy
Date: Fri, 2 Aug 2013 18:50:42 +0000
Message-ID: <A1A6EA40F8503D48BB002B42BD65974E0A0E6C8C@039-SN2MPN1-012.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: "'peppe.cavallaro@st.com'" <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0252.outbound.messaging.microsoft.com ([213.199.154.252]:26225
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754593Ab3HBSvk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 14:51:40 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

This regarding the patch prepared by you for adding RTL8211E support in
drivers/net/phy/realtek.c

commit ef3d90491a15f0d5cf1ec39a38a45dac6968fb2a
Author: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date:   Wed Jan 23 00:30:03 2013 +0000

    net: phy: realtek: add rtl8211e driver
    
    This patch adds the minimal driver to manage the
    Realtek RTL8211E 10/100/1000 Transceivers.

I see a macro specific to 8211E:
+#define        RTL8211E_INER_LINK_STAT 0x10

I was having a look at the RTL8211E(G) datasheet and could see
the following bit positions for INER register (Address 0x12):

[7:1] as Reserved
[0] as Jabber Interrupt

If I am not wrong a value 0x10 written to the INER register tries to set bit [4] which seems
Reserved.

Or am I missing something here.
Please let me know your views on the same.

Thanks,
Bhupesh 

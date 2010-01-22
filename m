From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to
 fs_enet driver
Date: Fri, 22 Jan 2010 10:35:59 +0100
Message-ID: <4B59717F.6090200@grandegger.com>
References: <1264039999-25731-3-git-send-email-agust@denx.de>	<20100121.012235.161201297.davem@davemloft.net>	<4B5871F2.9090005@grandegger.com> <20100121.180311.228791894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: agust@denx.de, netdev@vger.kernel.org, dzu@denx.de, wd@denx.de,
	jcrigby@gmail.com, kosmo@semihalf.com, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:58583 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190Ab0AVJhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 04:37:06 -0500
In-Reply-To: <20100121.180311.228791894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wolfgang Grandegger <wg@grandegger.com>
> Date: Thu, 21 Jan 2010 16:25:38 +0100
> 
>> Do you see a more clever solution to this problem?
> 
> See how we handle this in the ESP scsi driver.  We have a set of
> defines for the register offsets, and a set of methods a chip driver
> implements for register accesses.
> 
> If the offsets differ, the register access method can translate the
> generic register offsets into whatever layout their implementation
> actually uses.

I think you speak about:

    void (*esp_write8)(struct esp *esp, u8 val, unsigned long reg);
    u8 (*esp_read8)(struct esp *esp, unsigned long reg);

But still we need to translate the *generic* offset (reg) into the real
offset, which requires a lookup/table to get it. For me this seems not
really more efficient and less transparent as it bends the offsets.

Wolfgang.



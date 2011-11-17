From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.1.0 rtl8169_open oops.
Date: Thu, 17 Nov 2011 01:34:36 +0100
Message-ID: <20111117003436.GA3097@electric-eye.fr.zoreil.com>
References: <20111115223701.GA31118@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-team@fedoraproject.org,
	hayeswang@realtek.com
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55241 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab1KQAj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 19:39:59 -0500
Content-Disposition: inline
In-Reply-To: <20111115223701.GA31118@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> :
[...]
> (gdb) list *(rtl8169_open)+0x34e
> 0x4c0f is in rtl8169_open (drivers/net/r8169.c:1881).
> 1876		bool rc = false;
> 1877	
> 1878		if (fw->size < FW_OPCODE_SIZE)
> 1879			goto out;
> 1880	
> 1881		if (!fw_info->magic) {
> 1882			size_t i, size, start;
> 1883			u8 checksum = 0;
> 1884	
> 1885			if (fw->size < sizeof(*fw_info))

Give me 24h. I hope it is not as trivial as it seems :o(

Btw the firmware included in F16 is not up-to-date (see
http://marc.info/?l=linux-kernel&m=131295492507686&w=2). The driver should
not mind though.

-- 
Ueimor

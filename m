From: Dave Jones <davej@redhat.com>
Subject: Re: 3.1.0 rtl8169_open oops.
Date: Wed, 16 Nov 2011 19:53:55 -0500
Message-ID: <20111117005355.GA8466@redhat.com>
References: <20111115223701.GA31118@redhat.com>
 <20111117003436.GA3097@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-team@fedoraproject.org,
	hayeswang@realtek.com, dwmw2@infradead.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754173Ab1KQAyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 19:54:10 -0500
Content-Disposition: inline
In-Reply-To: <20111117003436.GA3097@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 01:34:36AM +0100, Francois Romieu wrote:
 > Dave Jones <davej@redhat.com> :
 > [...]
 > > (gdb) list *(rtl8169_open)+0x34e
 > > 0x4c0f is in rtl8169_open (drivers/net/r8169.c:1881).
 > > 1876		bool rc = false;
 > > 1877	
 > > 1878		if (fw->size < FW_OPCODE_SIZE)
 > > 1879			goto out;
 > > 1880	
 > > 1881		if (!fw_info->magic) {
 > > 1882			size_t i, size, start;
 > > 1883			u8 checksum = 0;
 > > 1884	
 > > 1885			if (fw->size < sizeof(*fw_info))
 > 
 > Give me 24h. I hope it is not as trivial as it seems :o(
 > 
 > Btw the firmware included in F16 is not up-to-date (see
 > http://marc.info/?l=linux-kernel&m=131295492507686&w=2). The driver should
 > not mind though.

That reminds me. Since the kernel.org compromise, where does
linux-firmware live now ?

That's probably why the version in Fedora hasn't been updated since July at a guess.

	Dave

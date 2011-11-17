From: hayeswang <hayeswang@realtek.com>
Subject: RE: 3.1.0 rtl8169_open oops.
Date: Thu, 17 Nov 2011 20:26:25 +0800
Message-ID: <0A34891812EB4560B3A1708BC58A0ECD@realtek.com.tw>
References: <20111115223701.GA31118@redhat.com> <20111117003436.GA3097@electric-eye.fr.zoreil.com> <20111117005355.GA8466@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-team@fedoraproject.org>,
	<dwmw2@infradead.org>
To: 'Dave Jones' <davej@redhat.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:36949 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756975Ab1KQM05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 07:26:57 -0500
In-Reply-To: <20111117005355.GA8466@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: Dave Jones [mailto:davej@redhat.com] 
> Sent: Thursday, November 17, 2011 8:54 AM
> To: Francois Romieu
> Cc: netdev@vger.kernel.org; kernel-team@fedoraproject.org; 
> Hayeswang; dwmw2@infradead.org
> Subject: Re: 3.1.0 rtl8169_open oops.
> 
> On Thu, Nov 17, 2011 at 01:34:36AM +0100, Francois Romieu wrote:
>  > Dave Jones <davej@redhat.com> :
>  > [...]
>  > > (gdb) list *(rtl8169_open)+0x34e
>  > > 0x4c0f is in rtl8169_open (drivers/net/r8169.c:1881).
>  > > 1876		bool rc = false;
>  > > 1877	
>  > > 1878		if (fw->size < FW_OPCODE_SIZE)
>  > > 1879			goto out;
>  > > 1880	
>  > > 1881		if (!fw_info->magic) {
>  > > 1882			size_t i, size, start;
>  > > 1883			u8 checksum = 0;
>  > > 1884	
>  > > 1885			if (fw->size < sizeof(*fw_info))
>  > 

My colleague tries Fedora 16 and it works fine with several different chips. We
couldn't reproduce the issue.

>  > Give me 24h. I hope it is not as trivial as it seems :o(
>  > 
>  > Btw the firmware included in F16 is not up-to-date (see
>  > http://marc.info/?l=linux-kernel&m=131295492507686&w=2). 
> The driver should
>  > not mind though.
> 
> That reminds me. Since the kernel.org compromise, where does
> linux-firmware live now ?
> 

I submitted the new firmwares to

http://git.kernel.org/pub/scm/linux/kernel/git/dwmw2/linux-firmware.git

However, the owner doesn't update them yet. You could reference

http://www.spinics.net/lists/netdev/msg178015.html

 
Best Regards,
Hayes

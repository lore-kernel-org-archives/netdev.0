From: Martin Capitanio <c4p7n@capitanio.org>
Subject: Re: [patch] rtl8102e: commit 7bf6bf480 zeroized MAC address
Date: Thu, 16 Oct 2008 13:19:59 +0200
Message-ID: <1224155999.9750.6.camel@marvin>
References: <200810151357.m9FDvZqk028829@post.webmailer.de>
	 <20081015225023.GB12337@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org,
	kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:32218 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372AbYJPLU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 07:20:28 -0400
In-Reply-To: <20081015225023.GB12337@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, den 16.10.2008, 00:50 +0200 schrieb Francois Romieu:
> c4p7n@capitanio.org <c4p7n@capitanio.org> :
> > May be we are reading just by luck zeros and not a random perfectly
> > sane address.
> 
> I would use the attached patches. The former one is mostly Ivan's one
> with some rework of the debug messages. The later checks the eeprom
> for its signature.

[ 8087.008071] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[ 8087.008108] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low) ->
IRQ 16
[ 8087.008120] r8169 0000:02:00.0: enabling Mem-Wr-Inval
[ 8087.008139] r8169 0000:02:00.0: enabling bus mastering
[ 8087.008149] r8169 0000:02:00.0: setting latency timer to 64
[ 8087.008284] r8169 0000:02:00.0: VPD access advertised.

[ 8087.008620] r8169 0000:02:00.0: Missing EEPROM signature: 0000

[ 8087.009390] eth0: RTL8102e at 0xffffc20000042000,, XID 34a00000 IRQ
316
[ 8091.040800] r8169: eth0: link up

Thanks,
Martin

> 
> With these patches the driver notices that it can not get an address
> for my 8168b but it works ok with my 8169 after both an hot and a
> cold boot. Interestingly enough, the VPD is not enabled on the 8169
> during the first boot.
> 
> Ivan, can you test them (and fix them afterwards :o) ) ?
> 


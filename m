From: David Miller <davem@davemloft.net>
Subject: Re: tun new missing ioctl32
Date: Thu, 29 Jan 2009 16:06:00 -0800 (PST)
Message-ID: <20090129.160600.73249925.davem@davemloft.net>
References: <49823F39.8080204@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mjt@tls.msk.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40446
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754201AbZA3AGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:06:02 -0500
In-Reply-To: <49823F39.8080204@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Tokarev <mjt@tls.msk.ru>
Date: Fri, 30 Jan 2009 02:43:53 +0300

> Just saw in dmesg:
> 
> ioctl32(kvm:4408): Unknown cmd fd(9) cmd(800454cf){t:'T';sz:4} arg(ffc668e4) on /dev/net/tun
> 
> I guess it's the recent stuff, TUNSETOFFLOAD perhaps, which is
> missing compat_ioctl entry...  Who knows this area, care to fix
> it please? :)

I'll take a look at this, thanks for the report.

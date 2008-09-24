From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: D945GCLF  intel atom board & r8169 ethernet broken in
	linux-2.6.27-rc5??
Date: Wed, 24 Sep 2008 22:19:03 +0200
Message-ID: <20080924201903.GA10546@electric-eye.fr.zoreil.com>
References: <9F6ACAE02B6DD040A1E259977622CFDB03F5BCCB@oslexcp1.eu.tandberg.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Kok, Auke" <auke-jan.h.kok@intel.com>
To: John Gumb <john.gumb@tandberg.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35023 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752160AbYIXUT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 16:19:27 -0400
Content-Disposition: inline
In-Reply-To: <9F6ACAE02B6DD040A1E259977622CFDB03F5BCCB@oslexcp1.eu.tandberg.int>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Gumb <john.gumb@tandberg.com> :
[...]
> With linux-2.6.27-rc5, "ifconfig eth0" just hangs. lspci -vvx reports,
> after loading the driver,
> 
> > 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E
> PCI Express Fast Ethernet controller (rev ff) (prog-if ff)
> >       !!! Unknown header type 7f
> 00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  
> 
> Before I load the driver lspci -vvx looks OK.

It is probably the driver's responsibility then.

> I do not have (much) time to look into this any further but hopefully
> this might help someone.

Can you try patches #0001 .. #0008 at
http://userweb.kernel.org/~romieu/r8169/2.6.27-rc6/20080913/ ?

-- 
Ueimor

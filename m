From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Disable polling in rtl8169_suspend() to prevent race
	with rtl8169_interrupt()
Date: Wed, 17 Oct 2007 18:40:21 +0200
Message-ID: <20071017164021.GA13105@electric-eye.fr.zoreil.com>
References: <200710161846.52509.fzu@wemgehoertderstaat.de> <200710162127.52228.fzu@wemgehoertderstaat.de> <20071016210412.GB8049@electric-eye.fr.zoreil.com> <200710170010.36329.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Karsten Wiese <fzu@wemgehoertderstaat.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44576 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758034AbXJQQn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 12:43:58 -0400
Content-Disposition: inline
In-Reply-To: <200710170010.36329.fzu@wemgehoertderstaat.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karsten Wiese <fzu@wemgehoertderstaat.de> :
[...]
> Can your patch cause the same effect as the "ethtool -s eth0 port mii" in
> the bug case?
> 
> Do you agree that rtl8169_interrupt() should not be called after
> rtl8169_asic_down() when in rtl8169_suspend() and before rtl8169_resume()?

I have not thought about it too deeply.

I'd rather say that the driver must be able to handle it. Spurious/shared
irq happen.

-- 
Ueimor

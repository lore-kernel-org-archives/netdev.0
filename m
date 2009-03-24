From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Tue, 24 Mar 2009 21:18:19 +0100
Message-ID: <20090324201819.GA22366@electric-eye.fr.zoreil.com>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <20090323224222.GA18951@electric-eye.fr.zoreil.com> <200903240138.32805.fzu@wemgehoertderstaat.de> <200903241454.15853.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Karsten Wiese <fzu@wemgehoertderstaat.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35864 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753302AbZCXUOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 16:14:41 -0400
Content-Disposition: inline
In-Reply-To: <200903241454.15853.fzu@wemgehoertderstaat.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten Wiese <fzu@wemgehoertderstaat.de> :
[...]
> patch below helps.

Thanks.

I'll wrap it up without the change to R8169_MSG_DEFAULT:
- it can be set through ethtool and a module option
- the current default is not a clear nuisance

-- 
Ueimor

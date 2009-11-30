From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: restore mac addr in rtl8169_remove_one and
 rtl_shutdown
Date: Sun, 29 Nov 2009 23:13:00 -0800 (PST)
Message-ID: <20091129.231300.208347664.davem@davemloft.net>
References: <1259087166-14558-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54398
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751064AbZK3HMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 02:12:54 -0500
In-Reply-To: <1259087166-14558-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Tue, 24 Nov 2009 19:26:06 +0100

> The newer chipsets (all PCI-E) are known that they need full power cycle
> (AC or battery removal) to reset MAC address to a  hardwired one. Previous
> patch to address this problem loads the original MAC address from EEPROM.
> But it brought other problem for which it is necessary to introduce a new
> module parameter.
> However, it might suffice to restore the initial MAC address before
> shutdown/reboot/kexec and when removing the module.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.

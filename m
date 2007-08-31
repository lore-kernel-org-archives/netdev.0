From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2] [02/10] pasemi_mac: Stop using the pci config space
 accessors for register read/writes
Date: Fri, 31 Aug 2007 09:54:23 -0400
Message-ID: <46D81D8F.3060208@pobox.com>
References: <20070817205413.548020000@lixom.net> <20070822141248.GC16830@lixom.net> <20070823181310.GB31882@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53456 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965246AbXHaNy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:54:26 -0400
In-Reply-To: <20070823181310.GB31882@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Move away from using the pci config access functions for simple register
> access.  Our device has all of the registers in the config space (hey,
> from the hardware point of view it looks reasonable :-), so we need to
> somehow get to it. Newer firmwares have it in the device tree such that
> we can just get it and ioremap it there (in case it ever moves in future
> products). For now, provide a hardcoded fallback for older firmwares.
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

applied 2-10



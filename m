From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 13:00:02 -0400
Message-ID: <45195C92.4040503@garzik.org>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net> <200609261804.37422.mb@bu3sch.de> <4519508A.4010004@garzik.org> <200609261820.46308.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:2441 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751574AbWIZRAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 13:00:05 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609261820.46308.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> #ifdef BIG_ENDIAN
> 	bp->phy_addr = eeprom[91] & 0x1f;
> #else
> 	bp->phy_addr = eeprom[90] & 0x1f;
> #endif

False.  It's already fixed endian.  It's just not the endian you like.

	Jeff



From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 19:14:22 +0200
Message-ID: <200609261914.22538.mb@bu3sch.de>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net> <200609261820.46308.mb@bu3sch.de> <45195C92.4040503@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:11915
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932153AbWIZROh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 13:14:37 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45195C92.4040503@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 26 September 2006 19:00, Jeff Garzik wrote:
> Michael Buesch wrote:
> > #ifdef BIG_ENDIAN
> > 	bp->phy_addr = eeprom[91] & 0x1f;
> > #else
> > 	bp->phy_addr = eeprom[90] & 0x1f;
> > #endif
> 
> False.  It's already fixed endian.  It's just not the endian you like.

Jeff, come on...
Read Johannes' mail.
readX returns CPU endian data.

-- 
Greetings Michael.

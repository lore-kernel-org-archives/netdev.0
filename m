From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Can someone please try...
Date: Tue, 16 Jan 2007 20:23:23 +0100
Message-ID: <200701162023.23919.mb@bu3sch.de>
References: <200701161806.02780.mb@bu3sch.de> <1168972142.8299.11.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:56151
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbXAPTYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 14:24:34 -0500
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <1168972142.8299.11.camel@dv>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 16 January 2007 19:29, Pavel Roskin wrote:
> On Tue, 2007-01-16 at 18:06 +0100, Michael Buesch wrote:
> > ...the bcm43xx driver in my tree with a 4318 chip?
> 
> Things are progressing for me a bit because I observed an association to
> an AP with no security.  I still had to use wpa_supplicant.
> 
> Unfortunately, there is a bigger issue with the new code.  When I
> interrupt wpa_supplicant, the kernel reports several oopses and then
> panics, so I have to reboot.  I had to use serial console just to
> capture the messages.
> 
> I assume the first message is most relevant.  Here it is:

A patch for that is already upstream.
It's surprising that it doesn't happen for me, though.
Neiter on PPC, nor on i386.

Patch was
[PATCH] bcm43xx-d80211: Fix DMA TX skb doublefree

-- 
Greetings Michael.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: ax88796: add 93cx6 eeprom support
Date: Thu, 27 Sep 2007 15:04:47 -0700
Message-ID: <20070927150447.a9af14c5.akpm@linux-foundation.org>
References: <20070927105119.6515.35298.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, magnus.damm@gmail.com, lethal@linux-sh.org,
	jgarzik@pobox.com, ben-linux@fluff.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48136 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752044AbXI0WFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 18:05:39 -0400
In-Reply-To: <20070927105119.6515.35298.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Sep 2007 19:51:19 +0900
Magnus Damm <magnus.damm@gmail.com> wrote:

> ax88796: add 93cx6 eeprom support
> 
> This patch hooks up the 93cx6 eeprom code to the ax88796 driver and modifies
> the ax88796 driver to read out the mac address from the eeprom. We need
> this for the ax88796 on certain SuperH boards. The pin configuration used
> to connect the eeprom to the ax88796 on these boards is the same as pointed
> out by the ax88796 datasheet, so we can probably reuse this code for multiple
> platforms in the future.

I'm showing a minor reject between this and Francois's git-r8169.patch.

***************
*** 21,33 ****
  /*
  	Module: eeprom_93cx6
  	Abstract: EEPROM reader datastructures for 93cx6 chipsets.
- 	Supported chipsets: 93c46 & 93c66.
   */
  
  /*
   * EEPROM operation defines.
   */
  #define PCI_EEPROM_WIDTH_93C46	6
  #define PCI_EEPROM_WIDTH_93C66	8
  #define PCI_EEPROM_WIDTH_OPCODE	3
  #define PCI_EEPROM_WRITE_OPCODE	0x05
--- 21,34 ----
  /*
  	Module: eeprom_93cx6
  	Abstract: EEPROM reader datastructures for 93cx6 chipsets.
+ 	Supported chipsets: 93c46/93c56/93c66.
   */
  
  /*
   * EEPROM operation defines.
   */
  #define PCI_EEPROM_WIDTH_93C46	6
+ #define PCI_EEPROM_WIDTH_93C56	8
  #define PCI_EEPROM_WIDTH_93C66	8
  #define PCI_EEPROM_WIDTH_OPCODE	3
  #define PCI_EEPROM_WRITE_OPCODE	0x05


You both made the same change to eeprom_93cx6.h.  That all sounds good but
it would be comforting if you could review each other's work, please...


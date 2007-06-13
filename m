From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'rtl8187' branch of wireless-2.6
Date: Wed, 13 Jun 2007 16:03:38 -0400
Message-ID: <46704D9A.6090001@garzik.org>
References: <20070613022143.GD4187@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andreamrl@tiscali.it, flamingice@sourmilk.net,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39166 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbXFMUDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:03:51 -0400
In-Reply-To: <20070613022143.GD4187@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Jeff,
> 
> This is the second round for the new mac80211-based rtl8187 driver.
> Michael and Ivo responded to many of the original review comments,
> and I have added a couple of patches to minimally address some
> remaining issues.  Please look at the comments I added to the header
> blocks to see if that is satisfactory regarding explanation of the
> magic values in the driver.
> 
> This is a new driver, so obviously it would be targeted towards 2.6.23.
> 
> John
> 
> ---
> 
> The following changes since commit 5ecd3100e695228ac5e0ce0e325e252c0f11806f:
>   Linus Torvalds (1):
>         Linux 2.6.22-rc4
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git rtl8187
> 
> Ivo van Doorn (2):
>       Add 93cx6 eeprom library
>       eeprom_93cx6: Add comment for 1us delay after pulse
> 
> John W. Linville (2):
>       eeprom_93cx6: shorten pulse timing to match spec
>       rtl8187: add header blocks and indicate origin of magic values
> 
> Michael Wu (1):
>       Add rtl8187 wireless driver
> 
>  MAINTAINERS                            |   10 +
>  drivers/misc/Kconfig                   |    5 +
>  drivers/misc/Makefile                  |    1 +
>  drivers/misc/eeprom_93cx6.c            |  241 +++++++++++
>  drivers/net/wireless/Kconfig           |   12 +
>  drivers/net/wireless/Makefile          |    3 +
>  drivers/net/wireless/rtl8187.h         |  145 +++++++
>  drivers/net/wireless/rtl8187_dev.c     |  731 +++++++++++++++++++++++++++++++
>  drivers/net/wireless/rtl8187_rtl8225.c |  745 ++++++++++++++++++++++++++++++++
>  drivers/net/wireless/rtl8187_rtl8225.h |   44 ++
>  drivers/net/wireless/rtl818x.h         |  226 ++++++++++
>  include/linux/eeprom_93cx6.h           |   72 +++
>  12 files changed, 2235 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/misc/eeprom_93cx6.c
>  create mode 100644 drivers/net/wireless/rtl8187.h
>  create mode 100644 drivers/net/wireless/rtl8187_dev.c
>  create mode 100644 drivers/net/wireless/rtl8187_rtl8225.c
>  create mode 100644 drivers/net/wireless/rtl8187_rtl8225.h
>  create mode 100644 drivers/net/wireless/rtl818x.h
>  create mode 100644 include/linux/eeprom_93cx6.h

pulled into #upstream (2.6.23)



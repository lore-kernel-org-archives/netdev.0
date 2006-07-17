From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [patch] ieee80211: TKIP requires CRC32
Date: Mon, 17 Jul 2006 08:28:07 -0700
Message-ID: <20060717152807.GE4888@kroah.com>
References: <200607141855_MC3-1-C4FF-BD1B@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Toralf Foerster <toralf.foerster@gmx.de>,
	linux-stable <stable@kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:26534 "EHLO perch.kroah.org")
	by vger.kernel.org with ESMTP id S1750867AbWGQPxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 11:53:12 -0400
To: Chuck Ebbert <76306.1226@compuserve.com>
Content-Disposition: inline
In-Reply-To: <200607141855_MC3-1-C4FF-BD1B@compuserve.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2006 at 06:51:41PM -0400, Chuck Ebbert wrote:
> ieee80211_crypt_tkip will not work without CRC32.
> 
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `ieee80211_tkip_encrypt':
> net/ieee80211/ieee80211_crypt_tkip.c:349: undefined reference to `crc32_le'
> 
> Reported by Toralf Foerster <toralf.foerster@gmx.de>
> 
> Signed-off-by: Chuck Ebbert <76306.1226@compuserve.com>

Queued to -stable, thanks.

greg k-h

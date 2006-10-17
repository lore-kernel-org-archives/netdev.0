From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] prism54: wpa support for fullmac cards
Date: Tue, 17 Oct 2006 17:32:36 -0400
Message-ID: <20061017213229.GC32614@tuxdriver.com>
References: <200610031457.33215.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:42761 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750745AbWJQVdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 17:33:10 -0400
To: chunkeey@web.de
Content-Disposition: inline
In-Reply-To: <200610031457.33215.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2006 at 02:57:33PM +0200, chunkeey@web.de wrote:
> This patch (prism54-en-wpa3.patch) brings WPA/WPA2(RSN) with 
> TKIP-Cipher to everyone with a FULLMAC Prism GT/Indigo/Duette card.
> I removed all the parts(e.g.: Hostapd Support) which are not relevant for 
> wpa_supplicant (client/managed mode).
> 
> now, you can connect to your WLAN with: 
> wpa_supplicant -Dwext -c{WPA_CONF} -i{WPA_ETH} -dd
> 
> This code is just for review & testers...
> so only a pre-signed-off for now. ;)
> Pre- Signed-off-by: Christian Lamparter <chunkeey@web.de>

I apologize for the late response.

I was going to include this patch in my pending branch, but I can't
get it to apply.  The rejects are a bit big for me to hand-resolve.

Please review the patch posting procedures documented here:

	http://linux.yyz.us/patch-format.html

Feel free to resubmit the patch, based of the current wireless-2.6 tree:

	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com

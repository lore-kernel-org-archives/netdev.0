From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v2] carl9170: Clarify kconfig text
Date: Mon, 18 Apr 2016 19:10:57 +0200
Message-ID: <5517762.PotoMG0SZb@debian64>
References: <c17f2f12-1c94-6b19-c918-0a6a9ee401ca@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Lauri Kasanen <cand@gmx.com>, Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	Linux Firmware Maintainers <linux-firmware@kernel.org>,
	sgruszka@redhat.com
To: Xose Vazquez Perez <xose.vazquez@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c17f2f12-1c94-6b19-c918-0a6a9ee401ca@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, April 18, 2016 06:47:44 PM Xose Vazquez Perez wrote:
> Christian Lamparter wrote:
> 
> > Sure, but this could be a different patch then. I think Intel devices 
> > (iwlwifi, iwlegacy and ipw2x00) have a similar text about "download
> > firmware from this device from our homepage here" too. So if we want,
> > we can remove them altogether?
> 
> linux-firmware.git does not contain firmware for all drivers. _At least_
> zd1211rw [1], atmel [2] and ipw2x00 [3] are out of the tree.

Yeah, don't forget p54. It needs out-of-tree firmwares as well.

But what about iwlegacy? Isn't that another candidate that would fit both
requirements (no recent firmware update, firmware in linux-firmware.git) ?

> [1] http://sf.net/projects/zd1211/files/
> [2] http://web.archive.org/web/20121016132320/http://at76c503a.berlios.de/fw_dl.html
> [3] http://ipw2100.sf.net/firmware.php http://ipw2200.sf.net/firmware.php

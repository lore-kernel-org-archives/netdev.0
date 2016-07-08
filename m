From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: mask PCIe interrupts before removal
Date: Fri,  8 Jul 2016 13:48:42 +0000 (UTC)
Message-ID: <20160708134842.0AA02611CB@smtp.codeaurora.org>
References: <1467325262-82799-1-git-send-email-briannorris@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	<linux-kernel@vger.kernel.org>,
	Doug Anderson <dianders@chromium.org>,
	Brian Norris <computersforpeace@gmail.com>,
	Stephen Barber <smbarber@chromium.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Brian Norris <briannorris@chromium.org>
To: Brian Norris <briannorris@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57491 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932529AbcGHNsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 09:48:43 -0400
In-Reply-To: <1467325262-82799-1-git-send-email-briannorris@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Norris <briannorris@chromium.org> wrote:
> The PCIe driver didn't mask the host interrupts before trying to tear
> down. This causes lockups at reboot or rmmod when using MSI-X on 8997,
> since the MSI handler gets confused and locks up the system.
> 
> Also tested on 8897, which does not support MSI-X (and wasn't
> experiencing this same bug). No regressions seen there.
> 
> Signed-off-by: Brian Norris <briannorris@chromium.org>
> Tested-by: Douglas Anderson <dianders@chromium.org>

Thanks, 1 patch applied to wireless-drivers-next.git:

d41376ca8ba7 mwifiex: mask PCIe interrupts before removal

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9209027/

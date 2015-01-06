From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 11/28] net: wireless: ath: ath5k: drop owner assignment from platform_drivers
Date: Tue, 06 Jan 2015 20:41:41 +0200
Message-ID: <87bnmbycnu.fsf@kamboji.qca.qualcomm.com>
References: <1419196495-9626-1-git-send-email-wsa@the-dreams.de>
	<1419196495-9626-12-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419196495-9626-12-git-send-email-wsa@the-dreams.de> (Wolfram
	Sang's message of "Sun, 21 Dec 2014 22:14:32 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wolfram Sang <wsa@the-dreams.de> writes:

> This platform_driver does not need to set an owner, it will be populated by the
> driver core.
>
> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
> ---
> Generated with coccinelle. SmPL file is in the introductory msg. The big
> cleanup was pulled in this merge window. This series catches the bits fallen
> through. The patches shall go in via the subsystem trees.

Thanks, applied to wireless-drivers-next.git. But I simplified the patch
title:

c0c3163a7213 ath5k: drop owner assignment from platform_drivers

-- 
Kalle Valo

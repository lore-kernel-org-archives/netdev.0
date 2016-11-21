From: miaoqing@codeaurora.org
Subject: Re: [PATCH 4.9.0-rc5] AR9300 calibration problems with antenna
 selected
Date: Mon, 21 Nov 2016 13:48:03 +0800
Message-ID: <2ea016e563f5db553f201a7d4205c2c0@codeaurora.org>
References: <m3wpg52hii.fsf@t19.piap.pl>
 <61055e757c5645dfb69da3fc555cbcf5@aptaiexm02f.ap.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: =?UTF-8?Q?Krzysztof_Ha=C5=82asa?= <khalasa@piap.pl>,
        ath9k-devel <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56890 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbcKUFsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 00:48:05 -0500
In-Reply-To: <61055e757c5645dfb69da3fc555cbcf5@aptaiexm02f.ap.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I would prefer that you didn't submit this.

> 
> I recently tried to select a single antenna on AR9300 and it works for
> 30 seconds only. The subsequent calibration makes the RX signal level
> to drop from the usual -30/-40 dBm to -70/-80 dBm, and the
> transmission practically stops.
> 
> With the attached patch it works, though selecting the antenna doesn't
> seem to have any visible effect, at least with "iw wlanX station dump"
> (perhaps it works for TX).
> 
> I'm using ad-hoc mode:
> 
> rmmod ath9k
> modprobe ath9k
> iw dev wlan0 set type ibss
> iw phy phyX set antenna 2

2 is a bad mask. We use bitmap, the valid masks are 1, 3, 7.

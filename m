From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rsi: Fix possible leak when loading firmware
Date: Tue, 25 Aug 2015 12:38:02 +0000 (UTC)
Message-ID: <20150825123802.2C11B1405B0@smtp.codeaurora.org>
References: <1440191666-5104-1-git-send-email-cengelma@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mike.looijmans@topic.nl, khoroshilov@ispras.ru,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Christian Engelmayer <cengelma@gmx.at>
To: Christian Engelmayer <cengelma@gmx.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440191666-5104-1-git-send-email-cengelma@gmx.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Commit 5d5cd85ff441 ("rsi: Fix failure to load firmware after memory
> leak fix and fix the leak") also added a check on the allocation of
> DMA-accessible memory that may directly return. In that case the
> already allocated firmware data is leaked. Make sure the data is
> always freed correctly. Detected by Coverity CID 1316519.
> 
> Fixes: 5d5cd85ff441 ("rsi: Fix failure to load firmware after memory leak fix and fix the leak")
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo

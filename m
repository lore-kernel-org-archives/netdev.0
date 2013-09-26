From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH 04/11] ath: Remove extern from function prototypes
Date: Thu, 26 Sep 2013 10:30:00 +0300
Message-ID: <871u4ct4zr.fsf@kamboji.qca.qualcomm.com>
References: <cover.1380137609.git.joe@perches.com>
	<a3dabaf02d36dbb4051188b706a3e66e6465c56b.1380137609.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	"Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>,
	<ath10k@lists.infradead.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	<ath9k-devel@lists.ath9k.org>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:29894 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313Ab3IZHaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 03:30:14 -0400
In-Reply-To: <a3dabaf02d36dbb4051188b706a3e66e6465c56b.1380137609.git.joe@perches.com>
	(Joe Perches's message of "Wed, 25 Sep 2013 12:37:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:

> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
>
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/ath/ath10k/debug.h  | 8 ++++----
>  drivers/net/wireless/ath/ath6kl/common.h | 3 +--
>  drivers/net/wireless/ath/ath6kl/debug.h  | 9 ++++-----
>  drivers/net/wireless/ath/ath9k/ath9k.h   | 2 +-
>  4 files changed, 10 insertions(+), 12 deletions(-)

For the ath10k and ath6kl changes:

Acked-by: Kalle Valo <kvalo@qca.qualcomm.com>

-- 
Kalle Valo

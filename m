From: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Subject: Re: [PATCH 3/8] wireless: ipw2200: fix old-style declaration
Date: Fri, 24 Jun 2016 21:46:54 +0400
Message-ID: <CA++WF2MkLgLNNnjrtUbKE7wJ_XHhq8SU_g93XkykoUEoUYOMdw@mail.gmail.com>
References: <20160616135020.3154461-1-arnd@arndb.de> <20160616135245.3198419-1-arnd@arndb.de>
 <20160616135245.3198419-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:36684 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbcFXRqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 13:46:55 -0400
In-Reply-To: <20160616135245.3198419-3-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16 June 2016 at 17:52, Arnd Bergmann <arnd@arndb.de> wrote:
> Modern C standards expect the 'inline' keyword to come before the return
> type in a declaration, and we get a warning for this with "make W=1":
>
> drivers/net/wireless/intel/ipw2x00/ipw2200.c:4096:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/wireless/intel/ipw2x00/ipw2200.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>

Acked-by: Stanislav Yakovlev <stas.yakovlev@gmail.com>

Stanislav.

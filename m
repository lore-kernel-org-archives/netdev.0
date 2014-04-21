From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: ethoc: remove ethoc_config
Date: Mon, 21 Apr 2014 21:43:15 +0400
Message-ID: <CAMo8BfLhjB0+vcm+rw2pvoU1742b_wkXqqepMTtJt19VZKiybQ@mail.gmail.com>
References: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
	<1398096563-8786-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, bh74.an@samsung.com,
	ks.giri@samsung.com, siva.kallam@samsung.com,
	peppe.cavallaro@st.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:34744 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbaDURnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 13:43:16 -0400
Received: by mail-oa0-f51.google.com with SMTP id i4so4529961oah.38
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 10:43:15 -0700 (PDT)
In-Reply-To: <1398096563-8786-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2014 at 8:09 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> ethoc_config() returns -ENOSYS and does not implement anything useful,
> let's remove it such that net/core/dev_ioctl.c::dev_ifsioc can return
> something meaningful like -EOPNOTSUPP.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/ethoc.c | 6 ------
>  1 file changed, 6 deletions(-)

Reviewed-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max

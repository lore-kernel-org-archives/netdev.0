From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: Fix potential memory leak in dev_set_alias()
Date: Wed, 08 Aug 2012 16:07:04 -0700 (PDT)
Message-ID: <20120808.160704.588005225667606586.davem@davemloft.net>
References: <1344422005-21993-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344422005-21993-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Wed,  8 Aug 2012 14:33:25 +0400

> Do not leak memory by updating pointer with potentially NULL realloc return value.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied, thanks.

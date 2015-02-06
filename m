From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcm80211: Delete unnecessary checks before two function calls
Date: Fri,  6 Feb 2015 06:53:32 +0000 (UTC)
Message-ID: <20150206065332.BE03D140D11@smtp.codeaurora.org>
References: <54D275A7.3050701@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D275A7.3050701@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Wed, 4 Feb 2015 20:28:49 +0100
> 
> The functions brcmu_pkt_buf_free_skb() and usb_free_urb() test whether
> their argument is NULL and then return immediately. Thus the test around
> the call is not needed.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo

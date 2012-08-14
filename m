From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] net: Checking usb_register() return value
Date: Tue, 14 Aug 2012 17:34:04 +0300
Message-ID: <502A61DC.6070902@qca.qualcomm.com>
References: <1344931890-15763-1-git-send-email-makienko@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ldv-project@ispras.ru>,
	ath6kl-devel <ath6kl-devel@qualcomm.com>
To: Marina Makienko <makienko@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344931890-15763-1-git-send-email-makienko@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/14/2012 11:11 AM, Marina Makienko wrote:
> ath6kl_usb_init() does not check usb_register() return value.
> As a result it may incorrectly report success of driver initialization.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Marina Makienko <makienko@ispras.ru>

Thanks, applied to ath6kl.git. But I changed the title to use "ath6kl:"
and made some cosmetic changes to the code.

Kalle

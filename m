From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/3] rtlwifi: don't add include path for rtl8188ee
Date: Tue, 19 Jul 2016 18:17:59 +0000 (UTC)
Message-ID: <20160719181759.1AEB860239@smtp.codeaurora.org>
References: <20160719153403.2967812-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Jes Sorensen <Jes.Sorensen@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719153403.2967812-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> For rtl8188ee, we pass -Idrivers/net/wireless/rtlwifi/ to gcc,
> however that directy no longer exists, so evidently this option
> is no longer required here and can be removed to avoid a warning
> when building with 'make W=1' or 'gcc -Wmissing-include-dirs'
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks, 1 patch applied to wireless-drivers-next.git:

944c07a7aac9 rtlwifi: don't add include path for rtl8188ee

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9237723/

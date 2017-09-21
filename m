From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath10: mark PM functions as __maybe_unused
Date: Thu, 21 Sep 2017 15:05:15 +0000
Message-ID: <87poak853p.fsf@kamboji.qca.qualcomm.com>
References: <20170906125904.2588620-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Govind Singh <govinds@qti.qualcomm.com>,
        Ryan Hsu <ryanhsu@qti.qualcomm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        Rajkumar Manoharan <rmanohar@qti.qualcomm.com>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
        Colin Ian King <colin.king@canonical.com>,
        Ben Greear <greearb@candelatech.com>,
        Ashok Raj Nagarajan <arnagara@qti.qualcomm.com>,
        "bartosz.markowski@tieto.com" <bartosz.markowski@tieto.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906125904.2588620-1-arnd@arndb.de> (Arnd Bergmann's message
        of "Wed, 6 Sep 2017 14:58:53 +0200")
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> When CONFIG_PM_SLEEP is disabled, we get a compile-time
> warning:
>
> drivers/net/wireless/ath/ath10k/pci.c:3417:12: error: 'ath10k_pci_pm_resu=
me' defined but not used [-Werror=3Dunused-function]
>  static int ath10k_pci_pm_resume(struct device *dev)
>             ^~~~~~~~~~~~~~~~~~~~
> drivers/net/wireless/ath/ath10k/pci.c:3401:12: error: 'ath10k_pci_pm_susp=
end' defined but not used [-Werror=3Dunused-function]
>  static int ath10k_pci_pm_suspend(struct device *dev)
>
> Rather than fixing the #ifdef, this just marks both functions
> as __maybe_unused, which is a more robust way to do this.
>
> Fixes: 32faa3f0ee50 ("ath10k: add the PCI PM core suspend/resume ops")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to ath-current branch in ath.git, thanks.

(Having problems with my patchwork script so sending this manually)

--=20
Kalle Valo=

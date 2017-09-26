From: AceLan Kao <acelan.kao@canonical.com>
Subject: Re: [PATCH 2/6] ath9k: add a quirk to set use_msi automatically
Date: Tue, 26 Sep 2017 15:26:51 +0800
Message-ID: <CAFv23Qm9kZLSqJ_BP1D7mWCxekq0nt3S8onT1ckH-AoHDBUDzw@mail.gmail.com>
References: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
 <1506408099-18488-2-git-send-email-acelan.kao@canonical.com> <20170926064456.GA28611@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926064456.GA28611@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ath9k is an old driver for old chips, and they work fine with legacy INTx.
But some new platforms are using it, so I think we should list those
new platforms which blocks INTx in the driver.

BTW, new chips use ath10k driver.

2017-09-26 14:44 GMT+08:00 Christoph Hellwig <hch@infradead.org>:
> On Tue, Sep 26, 2017 at 02:41:35PM +0800, AceLan Kao wrote:
>> Some platform(BIOS) blocks legacy interrupts (INTx), and only allows MSI
>> for WLAN device. So adding a quirk to list those machines and set
>> use_msi automatically.
>> Adding Dell Inspiron 24-3460 to the quirk.
>
> Huh?  Using MSI should be the default, and skipping MSI should be
> a quirk if needed at all (usually it should be autodetected)

From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 2/6] ath9k: add a quirk to set use_msi automatically
Date: Tue, 26 Sep 2017 17:14:53 +0300
Message-ID: <878th14kde.fsf@kamboji.qca.qualcomm.com>
References: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
        <1506408099-18488-2-git-send-email-acelan.kao@canonical.com>
        <20170926064456.GA28611@infradead.org>
        <CAFv23Qm9kZLSqJ_BP1D7mWCxekq0nt3S8onT1ckH-AoHDBUDzw@mail.gmail.com>
        <20170926140413.GA19977@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: AceLan Kao <acelan.kao@canonical.com>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        "Linux-Kernel\@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
        Daniel Drake <drake@endlessm.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926140413.GA19977@infradead.org> (Christoph Hellwig's
        message of "Tue, 26 Sep 2017 07:04:13 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch@infradead.org> writes:

> On Tue, Sep 26, 2017 at 03:26:51PM +0800, AceLan Kao wrote:
>> Ath9k is an old driver for old chips, and they work fine with legacy INTx.
>> But some new platforms are using it, so I think we should list those
>> new platforms which blocks INTx in the driver.
>
> And unless they are broken and need a quirk they should work even better
> with MSI if the device advertises MSI support in the PCI capabilities.

Daniel Drake (CCed) already found problems with the MSI implementation:

https://lkml.kernel.org/r/20170925041153.26574-1-drake@endlessm.com

-- 
Kalle Valo

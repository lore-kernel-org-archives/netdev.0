From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/6] ath9k: add a quirk to set use_msi automatically
Date: Tue, 26 Sep 2017 07:04:13 -0700
Message-ID: <20170926140413.GA19977@infradead.org>
References: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
 <1506408099-18488-2-git-send-email-acelan.kao@canonical.com>
 <20170926064456.GA28611@infradead.org>
 <CAFv23Qm9kZLSqJ_BP1D7mWCxekq0nt3S8onT1ckH-AoHDBUDzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: AceLan Kao <acelan.kao@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:58108 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934425AbdIZOEP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 10:04:15 -0400
Content-Disposition: inline
In-Reply-To: <CAFv23Qm9kZLSqJ_BP1D7mWCxekq0nt3S8onT1ckH-AoHDBUDzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 03:26:51PM +0800, AceLan Kao wrote:
> Ath9k is an old driver for old chips, and they work fine with legacy INTx.
> But some new platforms are using it, so I think we should list those
> new platforms which blocks INTx in the driver.

And unless they are broken and need a quirk they should work even better
with MSI if the device advertises MSI support in the PCI capabilities.

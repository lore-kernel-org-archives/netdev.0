From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/6] ath9k: add a quirk to set use_msi automatically
Date: Mon, 25 Sep 2017 23:44:57 -0700
Message-ID: <20170926064456.GA28611@infradead.org>
References: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
 <1506408099-18488-2-git-send-email-acelan.kao@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: AceLan Kao <acelan.kao@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506408099-18488-2-git-send-email-acelan.kao@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2017 at 02:41:35PM +0800, AceLan Kao wrote:
> Some platform(BIOS) blocks legacy interrupts (INTx), and only allows MSI
> for WLAN device. So adding a quirk to list those machines and set
> use_msi automatically.
> Adding Dell Inspiron 24-3460 to the quirk.

Huh?  Using MSI should be the default, and skipping MSI should be
a quirk if needed at all (usually it should be autodetected)

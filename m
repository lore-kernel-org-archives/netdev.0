From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: linux-next: manual merge of the net-next tree with the pci tree
Date: Wed, 21 Jun 2017 16:29:29 +0300
Message-ID: <877f05v58m.fsf@kamboji.qca.qualcomm.com>
References: <20170621115443.3e10f0bc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>,
        Brian Norris <briannorris@chromium.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170621115443.3e10f0bc@canb.auug.org.au> (Stephen Rothwell's
        message of "Wed, 21 Jun 2017 11:54:43 +1000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell <sfr@canb.auug.org.au> writes:

> Today's linux-next merge of the net-next tree got a conflict in:
>
>   drivers/net/wireless/marvell/mwifiex/pcie.c
>
> between commit:
>
>   c336cc0ee4eb ("PCI: Split ->reset_notify() method into
> ->reset_prepare() and ->reset_done()")
>
> from the pci tree and commit:
>
>   68efd0386988 ("mwifiex: pcie: stop setting/clearing 'surprise_removed'")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary.

Thanks, the fix looks good to me. I guess there's nothing I can do at
the moment and Linus needs to fix this when he pulls from Dave (or
Bjorn, whichever is the last)?

-- 
Kalle Valo

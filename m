From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: linux-next: manual merge of the net-next tree with the wireless-drivers tree
Date: Tue, 10 May 2016 09:43:16 +0300
Message-ID: <87futqh0qj.fsf@kamboji.qca.qualcomm.com>
References: <20160509103921.72146ce1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Sara Sharon <sara.sharon@intel.com>,
	linux-wireless@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160509103921.72146ce1@canb.auug.org.au> (Stephen Rothwell's
	message of "Mon, 9 May 2016 10:39:21 +1000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell <sfr@canb.auug.org.au> writes:

> Today's linux-next merge of the net-next tree got a conflict in:
>
>   drivers/net/wireless/intel/iwlwifi/mvm/tx.c
>
> between commit:
>
>   5c08b0f5026f ("iwlwifi: mvm: don't override the rate with the AMSDU len")
>
> from the wireless-drivers tree and commit:
>
>   d8fe484470dd ("iwlwifi: mvm: add support for new TX CMD API")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

I'm planning to fix this by merging wireless-drivers to
wireless-drivers-next later today and most likely tomorrow send a
wireless-drivers-next pull request to Dave.

-- 
Kalle Valo

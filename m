From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath10k: mac: remove unreachable negative return check
Date: Tue, 16 Jun 2015 13:14:46 +0300
Message-ID: <87a8w07yeh.fsf@kamboji.qca.qualcomm.com>
References: <1434039461-24899-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ath10k@lists.infradead.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434039461-24899-1-git-send-email-hofrat@osadl.org> (Nicholas Mc
	Guire's message of "Thu, 11 Jun 2015 18:17:41 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas Mc Guire <hofrat@osadl.org> writes:

> wait_event_timeout(), introduced in 'commit 5e3dd157d7e7 ("ath10k: mac80211
> driver for Qualcomm Atheros 802.11ac CQA98xx devices")' never returns < 0
> so the only failure condition to be checked is ==0 (timeout). Further the
> return type is long not int - an appropriately named variable is added 
> and the assignments fixed up.
>
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Thanks, applied.

-- 
Kalle Valo

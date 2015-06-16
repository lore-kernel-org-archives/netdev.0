From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath10k: txrx: remove unreachable negative return check and fixup type
Date: Tue, 16 Jun 2015 13:16:23 +0300
Message-ID: <87616o7ybs.fsf@kamboji.qca.qualcomm.com>
References: <1434039489-24934-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ath10k@lists.infradead.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:3737 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756455AbbFPKQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 06:16:29 -0400
In-Reply-To: <1434039489-24934-1-git-send-email-hofrat@osadl.org> (Nicholas Mc
	Guire's message of "Thu, 11 Jun 2015 18:18:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicholas Mc Guire <hofrat@osadl.org> writes:

> wait_event_timeout(), introduced in 'commit 5e3dd157d7e7 ("ath10k: mac80211
> driver for Qualcomm Atheros 802.11ac CQA98xx devices")' never returns < 0
> so the only failure condition to be checked is == 0 (timeout). Further the
> return type is long not int - an appropriately named variable is added
> and the assignments fixed up.
>
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Thanks, applied.

-- 
Kalle Valo

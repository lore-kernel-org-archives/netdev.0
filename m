From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH 2/3 RFC] ath10k: wmi: match wait_for_completion_timeout return type
Date: Fri, 13 Mar 2015 18:20:01 +0200
Message-ID: <87bnjwrhse.fsf@kamboji.qca.qualcomm.com>
References: <1426175362-8640-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ath10k@lists.infradead.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426175362-8640-1-git-send-email-hofrat@osadl.org> (Nicholas Mc
	Guire's message of "Thu, 12 Mar 2015 11:49:22 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas Mc Guire <hofrat@osadl.org> writes:

> Return type of wait_for_completion_timeout is unsigned long not int.
> An appropriately named unsigned long is added and the assignments fixed up.
> Rather than returning 0 (timeout) or a more or less random remaining time
> (completion success) this return 0 or 1 which also resolves the type of the
> functions being int.
>
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Why does patch 2 in this patchset have RFC in the title but patches 1
and 3 not? That just makes me confused, I can't tell what you want me to
do with the patches. Normally I just drop all patches (or patchsets)
which have RFC, and that's what I'm going to do now.

To save everyone's time, when submitting something please state clearly
what's your intention.

-- 
Kalle Valo

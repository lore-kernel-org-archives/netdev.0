From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH 1/1] ath10k: fixing wrong initialization of struct channel
Date: Tue, 21 Jul 2015 14:54:33 +0300
Message-ID: <87fv4hohdy.fsf@kamboji.qca.qualcomm.com>
References: <1437018933-25832-1-git-send-email-maninder1.s@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ath10k@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<pankaj.m@samsung.com>
To: Maninder Singh <maninder1.s@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:19906 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbbGULyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 07:54:41 -0400
In-Reply-To: <1437018933-25832-1-git-send-email-maninder1.s@samsung.com>
	(Maninder Singh's message of "Thu, 16 Jul 2015 09:25:33 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maninder Singh <maninder1.s@samsung.com> writes:

> chandef is initialized with NULL and on the very next line,
> we are using it to get channel, which is not correct.
>
> channel should be initialized after obtaining chandef.
>
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>

How did you find this bug?

-- 
Kalle Valo

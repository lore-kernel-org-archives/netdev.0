From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: ath9k: Delete an unnecessary check before the function
 call"relay_close"
Date: Fri,  6 Feb 2015 06:50:07 +0000 (UTC)
Message-ID: <20150206065007.0E82D140CC9@smtp.codeaurora.org>
References: <54D25CDC.3040405@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ath9k-devel@lists.ath9k.org, linux-wireless@vger.kernel.org,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D25CDC.3040405@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Wed, 4 Feb 2015 18:48:28 +0100
> 
> The relay_close() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo

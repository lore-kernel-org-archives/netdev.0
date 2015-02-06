From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: hostap: Delete an unnecessary check before the function call
 "kfree"
Date: Fri,  6 Feb 2015 06:52:15 +0000 (UTC)
Message-ID: <20150206065215.544AF140CED@smtp.codeaurora.org>
References: <54D26EA9.6020301@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <j@w1.fi>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D26EA9.6020301@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Wed, 4 Feb 2015 20:06:39 +0100
> 
> The kfree() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo

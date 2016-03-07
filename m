From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: Use to_delayed_work()
Date: Mon,  7 Mar 2016 12:23:54 +0000 (UTC)
Message-ID: <20160307122354.663816074A@smtp.codeaurora.org>
References: <20160217123336.GA30230@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akarwar@marvell.com, nishants@marvell.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50206 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbcCGMXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 07:23:55 -0500
In-Reply-To: <20160217123336.GA30230@amitoj-Inspiron-3542>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Introduce the use of to_delayed_work() helper function instead of open
> coding it with container_of()
> 
> A simplified version of the Coccinelle semantic patch used to make
> this change is:
> 
> //<smpl>
> @@
> expression a;
> symbol work;
> @@
> - container_of(a, struct delayed_work, work)
> + to_delayed_work(a)
> //</smpl>
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo

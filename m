From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 6/7] : tehuti Fix possible causing oops of net_rx_action
Date: Thu, 13 Dec 2007 16:07:29 +0900
Message-ID: <b25c3fa70712122307q88cae7pa6a464d75a27db2@mail.gmail.com>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
	 <20071212.071832.07747779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, baum@tehutinetworks.net, andy@greyhouse.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:55918 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763596AbXLMHH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 02:07:29 -0500
Received: by rv-out-0910.google.com with SMTP id k20so468358rvb.1
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 23:07:29 -0800 (PST)
In-Reply-To: <20071212.071832.07747779.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/13, David Miller <davem@davemloft.net>:
> From: "Joonwoo Park" <joonwpark81@gmail.com>
> Date: Wed, 12 Dec 2007 13:01:27 +0900
>
>
> Any time your trying to make a caller "happy" by adjusting
> a return value forcefully, it's a hack.
>
> And I stated this in another reply about this issue.
>
> Please do not fix the problem this way.
>
> The correct way to fix this is, if we did process a full
> "weight" or work, we should not netif_rx_complete() and
> we should not re-enable chip interrupts.
>
> Instead we should return the true "work_done" value and
> allow the caller to thus poll us one more time.
>

Thanks so much for your advice.
I agree, returning work_done itself exactly.
I will rework for these drivers.

Thanks.
Joonwoo

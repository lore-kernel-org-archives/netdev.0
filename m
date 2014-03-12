From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V1 net-next 3/7] mlx4: In RoCE allow guests to have multiple
 GIDS
Date: Wed, 12 Mar 2014 10:49:47 +0200
Message-ID: <53201FAB.3040208@mellanox.com>
References: <1394542976-20095-1-git-send-email-ogerlitz@mellanox.com>	<1394542976-20095-4-git-send-email-ogerlitz@mellanox.com> <20140312.010052.1153760698053567291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <roland@kernel.org>,
	<jackm@dev.mellanox.co.il>, <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:40958 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751231AbaCLIt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 04:49:56 -0400
In-Reply-To: <20140312.010052.1153760698053567291.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2014 07:00, David Miller wrote:
> I hate to be picky like this, but this second function could be improved.
>
> The first function is fine, it's named "get_*" and it really does return
> a value.
>
> But the second one, it's also named "get_*" but it doesn't return the
> stated value.  Instead, it assigns it into a structure.
>
> The return value is always zero, so I suggest you make it return void and
> adjust the name.  Perhaps "fill_in_real_sgid_index", since that states
> explicitly that the value is "filled in" to the passed ah_attr.
sure, will fix, thanks for spotting this small possible improvement

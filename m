From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: change TX coalescing defaults
Date: Tue, 06 Nov 2012 03:50:43 -0800
Message-ID: <1352202643.3140.917.camel@edumazet-glaptop>
References: <1352168442.3140.32.camel@edumazet-glaptop>
	 <CAPcc5Piw2f4y=PXRGN+_gUA3ogO6zzbhyvNFEf717_m8dejbWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Vimalkumar <j.vimal@gmail.com>, amirv@mellanox.com
To: Amir Mellanox <amirv.mellanox@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:63078 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab2KFLuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 06:50:46 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so390341iea.19
        for <netdev@vger.kernel.org>; Tue, 06 Nov 2012 03:50:46 -0800 (PST)
In-Reply-To: <CAPcc5Piw2f4y=PXRGN+_gUA3ogO6zzbhyvNFEf717_m8dejbWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-06 at 10:04 +0200, Amir Mellanox wrote:
> Eric Hi,
> 
> I will check and review your patch and return to you ASAP.
> 
> Regarding BQL, the driver has it over half a year now, In commit:
> 5b263f5374ea70daa61ed9f5cc5d8f4ac236efbd

Oh right, it seems I was not looking for right verbs or changelog
keywords ;)

Then I suspect my patch will help to keep inflight BQL counter lower and
reduce latencies.

Thanks

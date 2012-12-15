From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] xfrm: do not check x->km.state
Date: Sat, 15 Dec 2012 09:36:05 +0800
Message-ID: <CAJFZqHx3qT4xDsEDNqU8Viqn1_yh4Q8O-OnPOK_pYSfpBp+oUQ@mail.gmail.com>
References: <1355389560-7705-1-git-send-email-roy.qing.li@gmail.com>
	<20121213101948.GG18940@secunet.com>
	<20121213.141922.2249665409902614569.davem@davemloft.net>
	<CAJFZqHxZDAeZxLyxddtxCB6ucU6hMxH1TtWcMD2TZGRRA52-_g@mail.gmail.com>
	<20121214114545.GI18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:43927 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab2LOBgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 20:36:06 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so4985348vcd.19
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2012 17:36:05 -0800 (PST)
In-Reply-To: <20121214114545.GI18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/14 Steffen Klassert <steffen.klassert@secunet.com>:
>> 1. remove this check in xfrm_state_check_expire, and add a check in
>> xfrm_output_one
>>
>
> I think the first option ist the better one. It removes a superfluous
> check and we get some more statistics.

I see, thanks

-Roy

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] r8169: fix offloaded tx checksum for small packets.
Date: Fri, 17 May 2013 02:59:34 +0400
Message-ID: <519564D6.8050409@cogentembedded.com>
References: <20130516223857.GA20140@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	=?UTF-8?B?SG9sZ2VyIEhvZmZzdMOk?= =?UTF-8?B?dHRl?=
	<holger.hoffstaette@googlemail.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:65381 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734Ab3EPW7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:59:31 -0400
Received: by mail-lb0-f175.google.com with SMTP id v10so3729587lbd.34
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 15:59:30 -0700 (PDT)
In-Reply-To: <20130516223857.GA20140@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/17/2013 02:38 AM, Francois Romieu wrote:

> 8168evl offloaded checksums are wrong since
> e5195c1f31f399289347e043d6abf3ffa80f0005

     Please, also specify that commit's summary line in parens.

> pads small packets to
> 60 bytes (without ethernet checksum). Observed UDP checksums are
> typically wrong by the count of added bytes.
>
> It isn't worth compensating. Let's checksum by hand, then pad.
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Hayes Wang <hayeswang@realtek.com>
> Tested-by: Holger Hoffst=C3=A4tte <holger.hoffstaette@googlemail.com>

WBR, Sergei

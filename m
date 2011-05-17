From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with a
 'bitwise' type
Date: Tue, 17 May 2011 23:30:25 +0200
Message-ID: <BANLkTin1BjwyubQzZ9UrzK-fBej3AxZ5Ww@mail.gmail.com>
References: <1305658121.2848.29.camel@bwh-desktop> <20110517.152651.1785846817320651943.davem@davemloft.net>
 <1305666379.2848.45.camel@bwh-desktop> <20110517.171412.1017451005914294196.davem@davemloft.net>
 <1305667378.1722.65.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:65262 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307Ab1EQVaq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:30:46 -0400
Received: by qwk3 with SMTP id 3so488003qwk.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 14:30:45 -0700 (PDT)
In-Reply-To: <1305667378.1722.65.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/17 Joe Perches <joe@perches.com>:
> On Tue, 2011-05-17 at 17:14 -0400, David Miller wrote:
>> Accept that the compiler currently doesn't want to allow enums to be
>> used as bit-masks, don't paper around it.
> A patch applied yesterday using enums as bitmasks:
> http://patchwork.ozlabs.org/patch/95802/

The compiler warning is about using enum-masks in switch() statement,
IIRC. In this case it might be enough to just add the mask to the
enum.

Best Regards,
Micha=B3 Miros=B3aw

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: Correct header retrieval after pskb_may_pull
Date: Wed, 29 Sep 2010 19:42:09 -0700 (PDT)
Message-ID: <20100929.194209.200378141.davem@davemloft.net>
References: <1285665042-20548-1-git-send-email-kumar.sanghvi@stericsson.com>
	<201009290023.44717.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kumar.sanghvi@stericsson.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, gulshan.karmani@stericsson.com,
	linus.walleij@stericsson.com
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37416
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789Ab0I3Cls convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 22:41:48 -0400
In-Reply-To: <201009290023.44717.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Wed, 29 Sep 2010 00:23:44 +0300

> On Tuesday 28 September 2010 12:10:42 ext Kumar A Sanghvi, you wrote:
>> From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
>>=20
>> Retrieve the header after doing pskb_may_pull since, pskb_may_pull
>> could change the buffer structure.
>>=20
>> This is based on the comment given by Eric Dumazet on Phonet
>> Pipe controller patch for a similar problem.
>>=20
>> Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
>> Acked-by: Linus Walleij <linus.walleij@stericsson.com>
 ...
> Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied, thanks everyone.

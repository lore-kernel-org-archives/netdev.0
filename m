From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Tue, 20 Apr 2010 07:38:17 +0800
Message-ID: <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
References: <1271452358.16881.4486.camel@edumazet-laptop> <1271520633.16881.4754.camel@edumazet-laptop>
	<20100419.130905.210660275.davem@davemloft.net> <20100419.132318.192086187.davem@davemloft.net>
	<1271709121.3845.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:49257 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab0DSXii convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 19:38:38 -0400
Received: by iwn35 with SMTP id 35so2625914iwn.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 16:38:37 -0700 (PDT)
In-Reply-To: <1271709121.3845.94.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 20, 2010 at 4:32 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> Hmm, this was not a formal patch, just an information.
>
> Problem is if hardware provides rxhash, will it be "consistent" too ?
>
>

Does this problem has relationship with your patch? No. If the rxhash
isn't provided by hardware, we can get more throughput from you patch,
and on the other side, we don't lose anything but potential more hash
collision.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

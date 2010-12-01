From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: bridge netpoll support: mismatch between net core and bridge headers
Date: Wed, 1 Dec 2010 16:53:31 -0500
Message-ID: <AANLkTi=hq6S_NvPEkTovkceUe9Orcitj_oHN1mVUW7+A@mail.gmail.com>
References: <AANLkTimbf+yfJFU29rNWAc-hXBxj92J=dNaShM04GNZ7@mail.gmail.com> <20101201.114201.245392768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52145 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399Ab0LAVxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 16:53:52 -0500
Received: by gxk1 with SMTP id 1so788848gxk.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 13:53:52 -0800 (PST)
In-Reply-To: <20101201.114201.245392768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 1, 2010 at 14:42, David Miller wrote:
> Mike Frysinger:
>> so in my randconfig builds, i'm now seeing frequent failures along the lines of:
>
> Mike, I cooked up a patch to "fix" this but I can't reproduce it
> in the current tree.
>
> No matter what I do, I can't get CONFIG_NETPOLL and
> CONFIG_NET_POLL_CONTROLLER to have different values.
>
> If I try to force it in my ".config" the subsequent "make oldconfig"
> forces them to be equal.

can you post a patch i can try in my randconfig tree ?
-mike

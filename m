From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 1/4] X.25 remove bkl in listen
Date: Wed, 15 Sep 2010 13:43:06 +1000
Message-ID: <AANLkTimT72LxUH9gsfKVWeZWiz1GQD-gU7kXO-6DtX-1@mail.gmail.com>
References: <1284507076.1742.51.camel@jaunty>
	<20100914.204017.226779854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47964 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234Ab0IODnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 23:43:08 -0400
Received: by wwd20 with SMTP id 20so619179wwd.1
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 20:43:06 -0700 (PDT)
In-Reply-To: <20100914.204017.226779854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, I'll test that and have a close look at it for the next round.

On Wed, Sep 15, 2010 at 1:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Andrew Hendry <andrew.hendry@gmail.com>
> Date: Wed, 15 Sep 2010 09:31:16 +1000
>
>> Listen updates socket values and needs lock_sock.
>>
>> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>
>
> Applied.
>
> Although you may want to think about whether we need to also hold the
> x25_list_lock as a writer here so that scanners of the socket list see
> consistent state changes.
>

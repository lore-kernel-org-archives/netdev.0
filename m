From: Andrey Wagin <avagin@gmail.com>
Subject: Re: linux-next: unregister_netdevice: waiting for lo to become free.
 Usage count = 1
Date: Wed, 19 Aug 2015 23:20:56 +0300
Message-ID: <CANaxB-yo6ONG9KBn_f7Fh9JWem19Q-1qZLv5PZUBk3V2PnPycw@mail.gmail.com>
References: <CANaxB-z52c-1jqN4fFFECpz1EaDC6B-62WyqtJqNJRiKLhyg7g@mail.gmail.com>
	<55D34ECF.9050909@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:33970 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbbHSUU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 16:20:58 -0400
Received: by lbbtg9 with SMTP id tg9so10870196lbb.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 13:20:57 -0700 (PDT)
In-Reply-To: <55D34ECF.9050909@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-08-18 18:27 GMT+03:00 David Ahern <dsa@cumulusnetworks.com>:
> On 8/18/15 9:24 AM, Andrey Wagin wrote:
>>
>> Hello David,
>>
>> CRIU tests detetect that references on net devices leak on
>> 4.2.0-rc6-next-20150817. Looks like it started with
>> v4.2-rc6-882-g3bfd847.
>
>
> 1e3136789975f03e461798149309034e5213c1b4 should have fixed it.

Yes, it works now. Thanks!

>
> David

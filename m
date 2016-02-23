From: Marcus Furlong <furlongm@gmail.com>
Subject: Re: iproute2 query
Date: Tue, 23 Feb 2016 11:19:14 +1100
Message-ID: <CAH4CTx6d1tcmyaSgzA8Lw7MbAbH_cxb4EBM9BSV13ALPv_FVUA@mail.gmail.com>
References: <CAH4CTx4zv_zEgdJYLehReC=JU0-uuWgVNRyLgSjS5CwhY8c2iA@mail.gmail.com>
 <20160221120525.24769852@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:36469 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbcBWATf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 19:19:35 -0500
Received: by mail-qg0-f46.google.com with SMTP id y9so126693022qgd.3
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 16:19:34 -0800 (PST)
In-Reply-To: <20160221120525.24769852@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22 February 2016 at 07:05, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 19 Feb 2016 20:12:04 +1100
> Marcus Furlong <furlongm@gmail.com> wrote:
>
>> Hi,
>>
>> Just wondering if the following command should work:
>>
>> # ip route add 192.168.27.27/24 dev eth0 scope link src 192.168.27.27
>> RTNETLINK answers: Invalid argument
>>
>> However, this command works:
>>
>> # ip route add 192.168.27.0/24 dev eth0 scope link src 192.168.27.27
>>
>> 192.168.27.0/24 and 192.168.27.27/24 describe the same subnet?
>>
>
> It is the kernel complaining, not ip command.
> The kernel will not accept 192.168.27.27/24 as route since it is a full
> network address, not an network prefix.

Would it be a bad idea for the ip command to validate the data, and
only submit the network bits to the kernel?

Regards,
Marcus.

-- 
Marcus Furlong

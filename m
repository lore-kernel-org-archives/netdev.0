From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 query
Date: Sun, 21 Feb 2016 12:05:25 -0800
Message-ID: <20160221120525.24769852@xeon-e3>
References: <CAH4CTx4zv_zEgdJYLehReC=JU0-uuWgVNRyLgSjS5CwhY8c2iA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marcus Furlong <furlongm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33826 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbcBUUFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 15:05:16 -0500
Received: by mail-io0-f180.google.com with SMTP id 9so158873747iom.1
        for <netdev@vger.kernel.org>; Sun, 21 Feb 2016 12:05:15 -0800 (PST)
In-Reply-To: <CAH4CTx4zv_zEgdJYLehReC=JU0-uuWgVNRyLgSjS5CwhY8c2iA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Feb 2016 20:12:04 +1100
Marcus Furlong <furlongm@gmail.com> wrote:

> Hi,
> 
> Just wondering if the following command should work:
> 
> # ip route add 192.168.27.27/24 dev eth0 scope link src 192.168.27.27
> RTNETLINK answers: Invalid argument
> 
> However, this command works:
> 
> # ip route add 192.168.27.0/24 dev eth0 scope link src 192.168.27.27
> 
> 192.168.27.0/24 and 192.168.27.27/24 describe the same subnet?
> 
> Regards,
> Marcus.
> 

It is the kernel complaining, not ip command.
The kernel will not accept 192.168.27.27/24 as route since it is a full
network address, not an network prefix.

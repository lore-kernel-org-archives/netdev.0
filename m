From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP using IPv4-mapped IPv6 address as source
Date: Wed, 11 Jan 2017 08:20:07 -0800
Message-ID: <1484151607.21472.55.camel@edumazet-glaptop3.roam.corp.google.com>
References: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: "Jonathan T. Leighton" <jtleight@udel.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36014 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752180AbdAKQUJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 11:20:09 -0500
Received: by mail-pf0-f193.google.com with SMTP id b22so16797819pfd.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 08:20:09 -0800 (PST)
In-Reply-To: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-05 at 16:25 -0500, Jonathan T. Leighton wrote:
> I've observed TCP using an IPv4-mapped IPv6 address as the source 
> address, which I believe contradicts 
> https://tools.ietf.org/html/rfc6890#page-14 (BCP 153). This occurs when 
> an IPv6 TCP socket, bound to a local IPv4-mapped IPv6 address, attempts 
> to connect to a remote IPv6 address. Presumable connect() should return 
> EAFNOSUPPORT in this case. Please advise me if this is not to 
> appropriate list to report this.

Hi Jonathan

I believe your concern makes sense.
Do you have a patch to address this issue ?

Thanks

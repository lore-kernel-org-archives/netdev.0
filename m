From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] core: Don't attempt to load the "" driver.
Date: Tue, 2 Sep 2014 11:25:24 -0700
Message-ID: <CAHA+R7P8=pkYfSoqhkiAkLc03V38_WCbqJdLxQKF_Y6YXNnbeg@mail.gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D174856B9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:58999 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754300AbaIBSZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 14:25:25 -0400
Received: by mail-la0-f52.google.com with SMTP id ty20so8293754lab.39
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 11:25:24 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174856B9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2014 at 6:48 AM, David Laight <David.Laight@aculab.com> wrote:
> While the applications shouldn't be calling an SIOCxxx ioctl with ifr_name[0] == 0
> the kernel shouldn't be tracing the error either.
>

Why don't we reject this empty string? It doesn't look like a valid one.
I assume this is for compatibility?

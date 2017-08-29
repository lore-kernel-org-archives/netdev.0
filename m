From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete
 it
Date: Tue, 29 Aug 2017 09:38:30 -0700 (PDT)
Message-ID: <20170829.093830.1915256661616331853.davem@davemloft.net>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
        <CAMuHMdUefXtqv9bFfgrkbu8NZRXeTD6qR-nErf6TCDz4L+OAWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, samuel@sortiz.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34840 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751447AbdH2Qib (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 12:38:31 -0400
In-Reply-To: <CAMuHMdUefXtqv9bFfgrkbu8NZRXeTD6qR-nErf6TCDz4L+OAWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 29 Aug 2017 12:59:00 +0200

> Hi Greg,
> 
> On Sun, Aug 27, 2017 at 5:03 PM, Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
>> The IRDA code has long been obsolete and broken.  So, to keep people
>> from trying to use it, and to prevent people from having to maintain it,
>> let's move it to drivers/staging/ so that we can delete it entirely from
>> the kernel in a few releases.
> 
> (diving into an early boot crash)
> 
> Have you tried running this? ;-)
> 
> irda_init() and net_dev_init() are both subsys_initcall()s.
> But the former now runs before the latter, leading to:

We must find a way to make the ordering proper again when both are
built-in.

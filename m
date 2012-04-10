From: Tim Hockin <thockin@hockin.org>
Subject: Re: [PATCH net-next #2 28/39] natsemi: stop using net_device.{base_addr,
 irq}.
Date: Tue, 10 Apr 2012 16:39:31 -0700
Message-ID: <CAAAKZwvRvc=6qwainJAkHCUEme+PsFY-s0PWxj9tYXwSmBcYJA@mail.gmail.com>
References: <1333704408.git.romieu@fr.zoreil.com> <d13055fe45a281c97ec85454ca8e1c2bc9932166.1333704409.git.romieu@fr.zoreil.com>
 <CAAAKZwu4D6QZ02gaRQ2pmF=tLyxjefu1c=H83cxAJq2TTgdxmA@mail.gmail.com> <20120410.193042.1153959183942458232.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:38412 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756662Ab2DJXjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 19:39:52 -0400
Received: by gghe5 with SMTP id e5so235002ggh.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 16:39:52 -0700 (PDT)
In-Reply-To: <20120410.193042.1153959183942458232.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, so that addresses that concern. :)  Thanks.

Overall nothing in the CL stands out as bad, except for the IO vs MMIO
BAR thing, which I can not answer with certainty any more.

On Tue, Apr 10, 2012 at 4:30 PM, David Miller <davem@davemloft.net> wrote:
> From: Tim Hockin <thockin@hockin.org>
> Date: Tue, 10 Apr 2012 15:53:53 -0700
>
>> First, because I am not so involved any more, I can't say with
>> certainty that these fields of struct net_device are not needed.
>
> It's the whole basis of this patch set, and described neatly
> in his "00/39" posting.

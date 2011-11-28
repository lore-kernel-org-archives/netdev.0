From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 4/5] tcp: allow undo from reordered DSACKs
Date: Mon, 28 Nov 2011 12:31:41 -0500
Message-ID: <CADVnQykS7w_OzQBa=Lqw=EU=qkXxsXeWSwfVrRj+_Yx4NgxHGw@mail.gmail.com>
References: <alpine.DEB.2.00.1111170715060.23028@melkinpaasi.cs.helsinki.fi>
	<CADVnQykNffEvpr5bnLiLyNGZiuhxx=5wxqFaZjC+Dk4mxe1Okw@mail.gmail.com>
	<alpine.DEB.2.00.1111221347290.31705@wel-95.cs.helsinki.fi>
	<20111127.185857.475440859115872225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	nanditad@google.com, ycheng@google.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62751 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab1K1Rbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 12:31:42 -0500
Received: by iage36 with SMTP id e36so9224317iag.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 09:31:41 -0800 (PST)
In-Reply-To: <20111127.185857.475440859115872225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2011 at 6:58 PM, David Miller <davem@davemloft.net> wrote:
> In order to make forward progress I've added Neil's patch to net-next.

Thanks!

>> Also, one (serious) word of caution! This change, by its extending of
>> CA_Open state, is somewhat similar to what I made FRTO years ago, and
>> managed to introduces subtle breaking to the state machine. Please check
>> that the problem similar to what was fixed by
>> a1c1f281b84a751fdb5ff919da3b09df7297619f does not reappear (possibly in
>> some other form causing spurious undos). ...To me it seems that
>> tcp_packet_delayed might be similarly confused after the given patch.
>
> Neil, please look into this so we can have any such issues fixed
> in time for the next merge window.

Absolutely. I will look into the areas that Ilpo mentioned.

neal

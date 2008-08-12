From: "Parag Warudkar" <parag.warudkar@gmail.com>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Mon, 11 Aug 2008 21:06:17 -0400
Message-ID: <82e4877d0808111806k1677170an3b7d87795c0b7f55@mail.gmail.com>
References: <20080809213101.0927a808.akpm@linux-foundation.org>
	 <489F8827.4030904@hp.com>
	 <82e4877d0808101805t55a6ec5ft6c9b171ac1c7c3ab@mail.gmail.com>
	 <20080811.143212.172434871.davem@davemloft.net>
	 <48A0CEEA.9080104@hp.com>
	 <82e4877d0808111701k8cf8b5p60623a65eb6bda95@mail.gmail.com>
	 <48A0DC27.7030208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:23141 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbYHLBGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:06:19 -0400
Received: by wx-out-0506.google.com with SMTP id h29so1439284wxd.4
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 18:06:18 -0700 (PDT)
In-Reply-To: <48A0DC27.7030208@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 8:41 PM, Brian Haley <brian.haley@hp.com> wrote:
> Parag Warudkar wrote:
>>
>> What output do you see with your patch?
>
> # ip -f inet6 route get fec0::1
> unreachable fec0::1 dev lo  table unspec  proto none  src
> 2001:1890:1109:a10:218:feff:fe7f:49c8  metric -1  error -101 hoplimit 255
>
> And if I down eth0 I get:
>
> # ip -f inet6 route get fec0::1
> unreachable fec0::1 dev lo  table unspec  proto none  src ::1  metric -1
>  error -101 hoplimit 255
>

Grrr. It looks like I was bitten by the infamous Netlink "No buffer space
available" error which I was somehow overlooked. Applying your patch to a
kernel which boots without the Netlink buffer space error shows the right
output.

Closing. Thanks.

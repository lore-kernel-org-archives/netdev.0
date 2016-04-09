From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver filter
Date: Sat, 9 Apr 2016 10:17:27 -0300
Message-ID: <CALx6S37x7FMfsn=T5e+=f7mz47nPgRBNpYYnA=NwmB-3cny1eg@mail.gmail.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
	<CALx6S34m8cVNgvuGp845bicixodfavH9cj-rARSwwEAvFCjd7g@mail.gmail.com>
	<20160409142759.25d8464a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes@sipsolutions.net>,
	eranlinuxmellanox@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35426 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbcDINR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 09:17:28 -0400
Received: by mail-io0-f181.google.com with SMTP id g185so161286349ioa.2
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 06:17:27 -0700 (PDT)
In-Reply-To: <20160409142759.25d8464a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 9, 2016 at 9:27 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Sat, 9 Apr 2016 08:17:04 -0300
> Tom Herbert <tom@herbertland.com> wrote:
>
>> One other API issue is how to deal with encapsulation. In this case a
>> header may be prepended to the packet, I assume there are BPF helper
>> functions and we don't need to return a new length or start?
>
> That reminds me.  Do the BPF program need to know the head-room, then?
>
Right, that is basically my question. Can we have a helper function in
BPF that will prepend n bytes to the buffer? (I don't think we want
expose a notion of headroom).

Tom

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer

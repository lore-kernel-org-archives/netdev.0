From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net/3.9] ipv6: ndisc: fix ndisc_send_redirect writing to
 the wrong skb
Date: Fri, 31 May 2013 11:23:11 +0800
Message-ID: <CAM_iQpWNAnRTgzjPTPxLU-eqz1nWqD=zyjTgwZaaxbwcpf4KMw@mail.gmail.com>
References: <51A66CF3.7010202@universe-factory.net>
	<5578958b49fff222740711e091c2325100f5a440.1369963643.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f49.google.com ([209.85.212.49]:61537 "EHLO
	mail-vb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab3EaDXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 23:23:12 -0400
In-Reply-To: <5578958b49fff222740711e091c2325100f5a440.1369963643.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 31, 2013 at 9:27 AM, Matthias Schiffer
<mschiffer@universe-factory.net> wrote:
> Since some refactoring in 5f5a011, ndisc_send_redirect called
> ndisc_fill_redirect_hdr_option on the wrong skb, leading to data corruption or
> in the worst case a panic when the skb_put failed.
>
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>


Good catch!

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

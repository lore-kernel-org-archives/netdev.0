From: Cong Wang <cwang@twopensource.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Mon, 13 Oct 2014 17:09:37 -0700
Message-ID: <CAHA+R7NOvmyDo_Up32z1oJKCEmCqywRyTkbio4i4n1J+bNg4Cw@mail.gmail.com>
References: <543AB655.6060603@winsoft.pl>
	<1413139613.9362.78.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7OWpjO0AbwteOAfxd1fej6BcjXR99xy+MnkZ8y+JZ8f4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>,
	netdev <netdev@vger.kernel.org>, edumazet@gmail.com,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:45979 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbaJNAJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 20:09:38 -0400
Received: by mail-qa0-f49.google.com with SMTP id f12so5113009qad.22
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 17:09:38 -0700 (PDT)
In-Reply-To: <CAHA+R7OWpjO0AbwteOAfxd1fej6BcjXR99xy+MnkZ8y+JZ8f4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2014 at 4:59 PM, Cong Wang <cwang@twopensource.com> wrote:
> Probably not related with this bug, but with regarding to the
> offending commit, what's the point of the memmove() in tcp_v4_rcv()
> since ip_rcv() already clears IPCB()?

Oh, ip options are actually saved in ip_rcv_finish()... Hmm, looks scary
to play with variable-length array with memmove()....

From: Ed Swierk <eswierk@bigswitch.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast groups
Date: Wed, 31 Aug 2011 15:00:39 -0700
Message-ID: <CAF5U64CE82LM=PTk5J70xakXeqYftNj9ix-2eb9BsGvyq19Bkg@mail.gmail.com>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
 <CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
 <20110711082755.0b38a15a@nehalam.ftrdhcpuser.net> <20110712113643.GC616804@jupiter.n2.diac24.net>
 <CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
 <20110715160357.GC1407585@jupiter.n2.diac24.net> <20110715163345.GD1407585@jupiter.n2.diac24.net>
 <20110727111714.GA2027462@jupiter.n2.diac24.net> <20110728084106.22166324@nehalam.ftrdhcpuser.net>
 <CAEJpZP3PHC32i8m74-ML6DDGii8ojJ6v12CqQ+v2MKEMSDU=7A@mail.gmail.com>
 <20110815112501.3a3c01ad@nehalam.ftrdhcpuser.net> <CAEJpZP0riOx=7umYgr3fV4JF31+8Jv8m6DRTkyyuiDnioff4Vw@mail.gmail.com>
 <20110831134904.1a050924@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nick Carter <ncarter100@gmail.com>,
	David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:49502 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756117Ab1HaWBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 18:01:20 -0400
Received: by gwaa12 with SMTP id a12so477482gwa.19
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 15:01:19 -0700 (PDT)
In-Reply-To: <20110831134904.1a050924@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2011 at 1:49 PM, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> I prefer the netfilter solution because it is more general. We already have
> a firewall solution why shouldn't this case be part of it?

For my application, I just want the bridge to forward all link-local
frames as well as regular frames between a pair of interfaces. It
seems a little odd to use a mechanism like netfilter to tell the
bridge _not_ to drop frames that would otherwise be dropped.

But other than that minor issue, my strong preference is that either
your or Nick's patch be committed as soon as possible :-)

--Ed

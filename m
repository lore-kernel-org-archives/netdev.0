From: Isaku Yamahata <yamahatanetdev@gmail.com>
Subject: Re: [PATCH net] core/dev: do not ignore dmac in dev_forward_skb()
Date: Tue, 12 Nov 2013 14:25:31 +0900
Message-ID: <20131112052531.GB22272@private.email.ne.jp>
References: <1384206735-4226-1-git-send-email-ast@plumgrid.com>
 <CAHo-Ooz8aqwOH6HBbBK3AD2=odCQtDyuV8+GdA4SqOWEwX6WTA@mail.gmail.com>
 <CAMEtUuzmZd0RXO+=YhCW7OwfE1kvc2aA2K0gqXRN+LwS-O1f2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	isaku.yamahata@gmail.com, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	yamahatanetdev@gmail.com
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:44218 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284Ab3KLF0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 00:26:07 -0500
Received: by mail-pd0-f180.google.com with SMTP id v10so2240204pde.25
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 21:26:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAMEtUuzmZd0RXO+=YhCW7OwfE1kvc2aA2K0gqXRN+LwS-O1f2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 05:12:10PM -0800,
Alexei Starovoitov <ast@plumgrid.com> wrote:

> On Mon, Nov 11, 2013 at 4:39 PM, Maciej =C5=BBenczykowski
> <zenczykowski@gmail.com> wrote:
> > Ack.
> >
> > I'm sure this breaks whatever the original commit was trying to 'fi=
x',
> > however it does so in a clearly incorrect manner by effectively
> > disabling dst mac address filtering.
>=20
> actually it doesn't break it. Isaku's testcase works for me.

The changeset of 963a88b31ddbbe99f38502239b1a46601773d217
  "tunnels: harmonize cleanup done on skb on xmit path"
addresses the issue by calling skb_scrub_packet() when sending skb
through tunnel. So it is safe to revert it.

thanks,
--=20
Isaku Yamahata <isaku.yamahata@gmail.com>

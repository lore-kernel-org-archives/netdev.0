From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_mirred: don't go back.
Date: Tue, 10 Nov 2009 16:50:25 +0800
Message-ID: <412e6f7f0911100050k39920adfl1ab70e345269833a@mail.gmail.com>
References: <4AF7B9F4.6010507@gmail.com> <1257751376.8009.2.camel@bigi>
	 <412e6f7f0911090031j16ab9c73o47f4d4d3ffd9be3a@mail.gmail.com>
	 <1257764086.6246.1.camel@bigi>
	 <412e6f7f0911090433j2b270663ycdf277110fbc6bac@mail.gmail.com>
	 <1257838834.3647.4.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:40424 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbZKJIuT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 03:50:19 -0500
Received: by pzk26 with SMTP id 26so2705196pzk.4
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 00:50:25 -0800 (PST)
In-Reply-To: <1257838834.3647.4.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 3:40 PM, jamal <hadi@cyberus.ca> wrote:
>
> I apologize - I am still not convinced this is a cleanup and i can
> already see holes you are introducing (example not freeing skb etc).

Where? After skb2 is allocated, there won't be any failure any more.

> You are putting me in a dilemma of not wanting to discourage you
> but at the same time not seeing this as a useful change to be made.
> Can we let this one slide?
>

It's just OK. When using tc, I also found act_mirred doesn't support
ingress, then I realized that there isn't any difference between
ingress and egress, as it depends on its parent. However I do think it
is confused, when it prints:
filter parent ffff: protocol ip pref 49152 basic handle 0x1
        action order 1: mirred (Egress Redirect to device ifb0) stolen
        index 5 ref 1 bind 1.
And the TODO note still is in the source code of act_mirred, it do
make me wonder for a while!

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

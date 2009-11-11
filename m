From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_mirred: don't go back.
Date: Wed, 11 Nov 2009 03:11:37 -0500
Message-ID: <1257927097.4685.4.camel@bigi>
References: <4AF7B9F4.6010507@gmail.com> <1257751376.8009.2.camel@bigi>
	 <412e6f7f0911090031j16ab9c73o47f4d4d3ffd9be3a@mail.gmail.com>
	 <1257764086.6246.1.camel@bigi>
	 <412e6f7f0911090433j2b270663ycdf277110fbc6bac@mail.gmail.com>
	 <1257838834.3647.4.camel@bigi>
	 <412e6f7f0911100050k39920adfl1ab70e345269833a@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:60075 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661AbZKKILa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 03:11:30 -0500
Received: by yxe17 with SMTP id 17so750880yxe.33
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 00:11:36 -0800 (PST)
In-Reply-To: <412e6f7f0911100050k39920adfl1ab70e345269833a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 2009-11-10 at 16:50 +0800, Changli Gao wrote:
 
> Where? After skb2 is allocated, there won't be any failure any more.


Sorry, yes, your change does look like an improvement.
If you can test a little more - please add my sign-off and submit.

> 
> It's just OK. When using tc, I also found act_mirred doesn't support
> ingress, then I realized that there isn't any difference between
> ingress and egress, as it depends on its parent. However I do think it
> is confused, when it prints:
> filter parent ffff: protocol ip pref 49152 basic handle 0x1
>         action order 1: mirred (Egress Redirect to device ifb0) stolen
>         index 5 ref 1 bind 1.
> And the TODO note still is in the source code of act_mirred, it do
> make me wonder for a while!

Well, you know if you have the energy - doing socket redirect would
be very interesting indeed. Ingress is another beast, it requires some
thinking and a lot more testing depending on the devices because of
possible loops.

cheers,
jamal


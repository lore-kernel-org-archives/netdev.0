From: Erwan Velu <erwanaliasr1@gmail.com>
Subject: Re: [PATCH] e100: expose broadcast_disabled as a module option
Date: Mon, 26 Apr 2010 10:49:55 +0200
Message-ID: <y2lb43bf5491004260149x23beb95dqc9e177d9a6ecc679@mail.gmail.com>
References: <l2nb43bf5491004231314i13503c67yeccfc54bc1cae850@mail.gmail.com>
	 <h2p9929d2391004231322r23528f32z8447a711a29e28ea@mail.gmail.com>
	 <20100423135816.23f5861f@nehalam>
	 <r2ob43bf5491004231403o64f8b88bsa9543d9910648d97@mail.gmail.com>
	 <20100423150207.7969c9f6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:42814 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab0DZIt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 04:49:57 -0400
In-Reply-To: <20100423150207.7969c9f6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Agreed that will be a better implementation. Changes of IFF_BROADCAST
could play with this "broadcast_disabled" configuration switch to
increase the cpu efficiency.

 I'm not a kernel expert and I don't really figure how the changes of
the IFF_BROADCAST should be forwarded to the interfaces and how it can
be manipulated. I saw that ifconfig have a '-broadcast' option but
looks like none of my drivers are compatible with that.

Does any one you could help me understanding what should be the good way to
1- enabled/disabled IFF_BROADCAST for a given interface
2- populate this changes to the driver

Once I'll be able to have a proper patch using that, I'll post it
again to the list.

Cheers,
Erwan

2010/4/24 Stephen Hemminger <shemminger@vyatta.com>:
> On Fri, 23 Apr 2010 23:03:59 +0200
[...]
> The point is that the driver can look at IFF_BROADCAST rather than having
> module parameter. Module parameters are device driver specific and should
> be avoid as much as possible in favor of general mechanism. This is a repeated
> problem where users and vendors make special hooks that only work with their
> driver, which makes life hard for other users and distribution providers.
>

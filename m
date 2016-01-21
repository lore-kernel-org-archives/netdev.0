From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] gro: Make GRO aware of lightweight tunnels.
Date: Thu, 21 Jan 2016 03:31:59 +0100
Message-ID: <20160121023159.GD29853@pox.localdomain>
References: <1453336048-49406-1-git-send-email-jesse@kernel.org>
 <1453337308.1223.345.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42g+bc-+=qjZ=Ha8580aZf5=o+2CS6pM1m-gKu47sbPTxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John <john.phillips5@hpe.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33025 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbcAUCcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:32:02 -0500
Received: by mail-wm0-f52.google.com with SMTP id 123so156271447wmz.0
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:32:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAEh+42g+bc-+=qjZ=Ha8580aZf5=o+2CS6pM1m-gKu47sbPTxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/16 at 05:47pm, Jesse Gross wrote:
> Just to merge the two threads together, all of protocols that would be
> affected by this also have "normal" GRO handlers that will run when
> the packet is first received. There's no argument that that is
> preferable if it is available. However, GRO cells do provide a
> performance benefit in other situations so it would be nice to avoid
> disabling it if possible.

I missed this thread when I replied to the other one.

What are these situations? It seems like there are specific
scenarios where this helps. Is it varying TLVs in the encap header
for otherwise meregable inner headers?

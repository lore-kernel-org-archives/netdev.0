From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 1/7] : e1000 Fix possible causing oops of net_rx_action
Date: Fri, 14 Dec 2007 11:41:26 +0900
Message-ID: <b25c3fa70712131841k6c06949evd247c9a2eabd9360@mail.gmail.com>
References: <000701c83d71$95536b10$9c94fea9@jason>
	 <20071213.053354.82143565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	jgarzik@pobox.com, shemminger@linux-foundation.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.190]:57300 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbXLNCl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 21:41:27 -0500
Received: by rv-out-0910.google.com with SMTP id k20so770707rvb.1
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 18:41:26 -0800 (PST)
In-Reply-To: <20071213.053354.82143565.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/13, David Miller <davem@davemloft.net>:
> From: "Joonwoo Park" <joonwpark81@gmail.com>
> Date: Thu, 13 Dec 2007 19:18:56 +0900
>
> > Just blowing netif_running up is not best solution I think, it makes
> > ifconfig down hang at least for e1000.
>
> It hangs because the packet receive rate is so high that NAPI
> poll never exits.

Certainly I'm aware it

>
> I think we need a cheap solution to something so obscure and
> almost not worth explicitly even coding for.  Really, if you
> setup silly situations like that, you get what you asked for.
>

I can agree that we need good solution for that.
BUT I don't think I didn't setup *silly* situation. my customers who
are reporting this problem, running firewall on linux which is
forwarding packets with high rate.
I don't want to say 'don't ifconfig down, don't reboot, don't
shutdown' it would introduce problem on your such *sily* sitution'.
In addition, my laptop is just connected to another *linux* machine
which is generating 300mbps 64byte udp packets infinitely.

Joonwoo

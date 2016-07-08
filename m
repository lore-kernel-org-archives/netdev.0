From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] vxlan: remove gro_cell support
Date: Fri, 08 Jul 2016 18:16:45 +0200
Message-ID: <1467994605.30694.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1467907022.git.pabeni@redhat.com>
	 <6f90239eb6ccb9145a886d4f01c6620c6d6ec87f.1467907022.git.pabeni@redhat.com>
	 <1467908002.1273.42.camel@edumazet-glaptop3.roam.corp.google.com>
	 <a7fd6676-4ba5-e1ec-7b57-9b4b7aee24be@stressinduktion.org>
	 <1467992022.30694.11.camel@edumazet-glaptop3.roam.corp.google.com>
	 <d032ddde-cde2-6b33-d929-90df119b5803@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34925 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbcGHQQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 12:16:56 -0400
Received: by mail-wm0-f49.google.com with SMTP id z126so16477246wme.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 09:16:55 -0700 (PDT)
In-Reply-To: <d032ddde-cde2-6b33-d929-90df119b5803@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 11:55 -0400, Hannes Frederic Sowa wrote:

> Exactly, thus we are also only touching UDP tunneling protocols at the
> moment. Did you nack the removal of gro_cell support from the udp
> protocols or are you fine with it, given that we won't take away the
> functionality to spread out skb_checksum to mulitple CPUs during GRO for
> other protocols and didn't plan to do so?

I am fine with it, but could you rephrase the changelog, otherwise some
people will think they can copy/paste this to other tunnels ?

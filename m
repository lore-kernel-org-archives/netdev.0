From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] about "net: orphan frags on receive" insanity
Date: Wed, 26 Jun 2013 12:09:24 -0700
Message-ID: <1372273764.3301.200.camel@edumazet-glaptop>
References: <1372235039.3301.126.camel@edumazet-glaptop>
	 <20130626095642.GA20982@redhat.com>
	 <1372241543.3301.157.camel@edumazet-glaptop>
	 <20130626185614.GA10713@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:32884 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029Ab3FZTJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 15:09:12 -0400
Received: by mail-ea0-f173.google.com with SMTP id g15so7789792eak.18
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 12:09:11 -0700 (PDT)
In-Reply-To: <20130626185614.GA10713@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 21:56 +0300, Michael S. Tsirkin wrote:

> Well we don't want to duplicate the whole RX path
> to special-case that, right?


Whats wrong using a helper ?

I_Should_cleanup_things(skb)
{
	... // cleanup for these special users trying to reenter stack

	netif_rx(skb);
}

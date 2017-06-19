From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: Re: [PATCH net-next] enic: use kasprintf instead of snprintf
Date: Sun, 18 Jun 2017 22:55:20 -0700
Message-ID: <alpine.LNX.2.20.1706182248450.15793@cae-iprp-alln-lb.cisco.com>
References: <20170619050537.6393-1-gvaradar@cisco.com> <1497850852.8495.41.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"; format=flowed
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <benve@cisco.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-9.cisco.com ([173.37.86.80]:52249 "EHLO
        rcdn-iport-9.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751089AbdFSGFG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 02:05:06 -0400
In-Reply-To: <1497850852.8495.41.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 Jun 2017, Joe Perches wrote:

> Perhaps it'd be better to use a style
> with a variable length format precision
>
> ie:
>
> 	"%.*s-tx-%u", IFNAMSIZ - 4 - <something>, netdev-name, i)
>

This would truncate interface name. Why is this preferred to my patch?

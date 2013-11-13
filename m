From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] htb: support 64bit rates
Date: Wed, 13 Nov 2013 06:21:50 -0800
Message-ID: <1384352510.28458.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384295647.28458.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52834248.3040103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:58292 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755066Ab3KMOVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 09:21:52 -0500
Received: by mail-pb0-f50.google.com with SMTP id xb12so471724pbc.23
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 06:21:51 -0800 (PST)
In-Reply-To: <52834248.3040103@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 17:11 +0800, Yang Yingliang wrote:
> > -	if (!buffer) buffer = opt.rate.rate / get_hz() + mtu;
> > -	if (!cbuffer) cbuffer = opt.ceil.rate / get_hz() + mtu;
> > +	if (!buffer)
> > +		buffer = rate64 / get_hz() + mtu;
> > +	if (!cbuffer)
> > +		cbuffer = ceil64 / get_hz() + mtu;
> 
> Hi,
> It may overflow here if rate64 and mtu are big enough.

Not really.

get_hz() on current kernels is really huge : 1000000000

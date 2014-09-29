From: Cong Wang <cwang@twopensource.com>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 29 Sep 2014 13:39:37 -0700
Message-ID: <CAHA+R7O_xghD4a5RD=omhnuMD72pRmKU9VMoxPUVuGcu682jBg@mail.gmail.com>
References: <52EFFE20.5080500@candelatech.com>
	<20140203220323.GB17999@order.stressinduktion.org>
	<52F012FF.9030105@candelatech.com>
	<52F65EB4.1050306@candelatech.com>
	<20140208172310.GF16198@order.stressinduktion.org>
	<loom.20140926T001736-777@post.gmane.org>
	<1411906297.2400343.172598909.66223582@webmail.messagingengine.com>
	<loom.20140929T195637-887@post.gmane.org>
	<5429A886.1040809@candelatech.com>
	<1412017399.14757.4.camel@localhost>
	<5429B783.20207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hongmei Li <duckcncn@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:40066 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaI2Uji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:39:38 -0400
Received: by mail-lb0-f170.google.com with SMTP id n15so7072801lbi.29
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 13:39:37 -0700 (PDT)
In-Reply-To: <5429B783.20207@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 12:48 PM, Ben Greear <greearb@candelatech.com> wrote:
>
> We are going to be running up to 20 concurrent scripts that
> will be dumping routes & ips, and configuring ip addresses
> and routes during bringup.
>
> I don't have a simple stand-alone way to reproduce this,
> but at least when we reported the problem is was very easy
> for us to reproduce with our tool.
>
> Maybe 20 scripts running in parallel that randomly configured and dumped routes
> and ip addresses on random interfaces would do the trick?
>

I think the most important question is why is this related with macvlan?
IPv6 is L3 while macvlan pure L2, if this is a IPv6 routing bug, it should
not be limited to macvlan.

What does your IPv6 routing table look like? And how do you configure those
macvlan interfaces?

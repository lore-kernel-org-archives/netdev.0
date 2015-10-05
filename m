From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 09/14] rocker: add rtnl ops for port mode
 [gs]etting
Date: Mon, 5 Oct 2015 19:24:07 +0200
Message-ID: <20151005172407.GS2278@nanopsycho.orion>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
 <1443993949-3915-10-git-send-email-jiri@resnulli.us>
 <CAE4R7bA6+_WUQ5BXD54zQK7DM64P3FS5D+TdUc1gcpbjd1+oZw@mail.gmail.com>
 <56129CD0.50301@gmail.com>
 <20151005163738.GP2278@nanopsycho.orion>
 <5612AE52.9040809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34209 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbJERYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:24:10 -0400
Received: by wicfx3 with SMTP id fx3so130658782wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:24:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5612AE52.9040809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 05, 2015 at 07:07:30PM CEST, john.fastabend@gmail.com wrote:

<snip>

>> 
>> Again, to make this clear, worlds are not just a rehash of tables.
>> 
>
>what are they then? Lets model those bits and let users configure them
>at runtime.
>
>So far I've had really good results modelling hardware as a 'parser',
>a set of tables, and a set of modify blocks. Now this breaks when you
>start to add black boxes in there for other functions such as encryption
>but I don't think your getting at that. Do you see something that
>couldn't be configured/modelled with those blocks?

How about an arbitrary BPF program? I can implement world that bases
mangling/forwarding packets on intensity of gravitational field.
Rocker hw is very free in that and cannot be pushed down to "table boxes".

That is making it a wild animal and challenges us to wrap it up in
kernel, somehow.

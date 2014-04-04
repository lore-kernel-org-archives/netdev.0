From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri, 04 Apr 2014 16:23:24 +0200
Message-ID: <533EC05C.50902@6wind.com>
References: <1396614038-31975-1-git-send-email-jiri@resnulli.us>	<20140404.095420.1460518706334112992.davem@davemloft.net>	<20140404140325.GB2892@minipsycho.brq.redhat.com> <20140404.100754.1337061118939924472.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edumazet@google.com, vfalico@redhat.com,
	stephen@networkplumber.org, hkchu@google.com, dborkman@redhat.com,
	willemb@google.com, hannes@stressinduktion.org,
	atzm@stratosphere.co.jp, phil@nwl.cc, richardcochran@gmail.com
To: David Miller <davem@davemloft.net>, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:32882 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151AbaDDOX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 10:23:28 -0400
Received: by mail-wi0-f171.google.com with SMTP id q5so1379508wiv.16
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 07:23:27 -0700 (PDT)
In-Reply-To: <20140404.100754.1337061118939924472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/04/2014 16:07, David Miller a =E9crit :
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Fri, 4 Apr 2014 16:03:25 +0200
>
>> Fri, Apr 04, 2014 at 03:54:20PM CEST, davem@davemloft.net wrote:
>>> From: Jiri Pirko <jiri@resnulli.us>
>>> Date: Fri,  4 Apr 2014 14:20:38 +0200
>>>
>>>> The priv is used now by af_packet. Rename it to make it useable fo=
r
>>>> others as well. Also, introduce packet_id_match to move the sk mat=
ching
>>>> from skb_loop_sk to af_packet code where it belongs.
>>>>
>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>
>>> Firstly, net-next is closed.
>>
>> Dave, it would be really great if you stick with the same email subj=
ect
>> when you declare net-next closed. I was looking for "CLOSED" but now=
 the
>> subject is "no new feature patches please" which I missed.
>
> Sorry, that's not a reasonable request.
>
> It is very clear from the subject line I choose what the message is
> about.  I don't have to use an ALL CAPS subject line "just because"
Sure, the subject is very clear. Personally I don't care, but I think t=
hat a
part of netdev subscribers/submitters don't read every emails. Having a=
lways
the same prefix (like the one you already used: '[README]') may ease th=
ese guys
to put some filters to highlight these emails. At the end, this may als=
o save
you time ;-)

My two cents,
Nicolas

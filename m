From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] iputils: ping by mark
Date: Sat, 17 Oct 2009 11:54:56 -0700
Message-ID: <55a4f86e0910171154v460146a8m1360fac71f9ddac8@mail.gmail.com>
References: <1255381558.5406.33.camel@dogo.mojatatu.com>
	 <7e84ed60910161405i2ce46053m9858b7f1c086e6b7@mail.gmail.com>
	 <1255782635.11213.7.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rob.Townley@gmail.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:44481 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194AbZJQSyx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 14:54:53 -0400
Received: by fxm18 with SMTP id 18so3597901fxm.37
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2009 11:54:57 -0700 (PDT)
In-Reply-To: <1255782635.11213.7.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch requires the currently being suggested/reviewed/written
'fix SO_MARK' patches, some of which have already been committed.

On Sat, Oct 17, 2009 at 05:30, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2009-10-16 at 16:05 -0500, Rob Townley wrote:
>
>> Would this make it easier to ping multiple gateways
>
> yes.
> You need to set your policy routing accordingly to have a different
> gateway for the same destination and then use the -m to select the
> routing table..
>
>> so if one goes
>> down, it is taken almost out of the routing table until it comes bac=
k
>> up.
>
> I am not sure i followed or see any relation to the first part of you=
r
> question.
> Ive never heard of routing table entries automagically being taken do=
wn
> until something comes up. You could do it probably by writting a user
> space daemon.
>
> cheers,
> jamal
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>

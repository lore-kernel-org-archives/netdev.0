From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Support specifying the network namespace upon device creation.
Date: Tue, 03 Nov 2009 02:06:36 -0800
Message-ID: <m1bpjjgbwz.fsf@fess.ebiederm.org>
References: <m1eioggeux.fsf@fess.ebiederm.org> <4AEFF7BB.4090301@gmail.com>
	<m1ws28ey3k.fsf@fess.ebiederm.org> <4AEFFE32.4050808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:38637 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172AbZKCKGe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 05:06:34 -0500
In-Reply-To: <4AEFFE32.4050808@gmail.com> (Eric Dumazet's message of "Tue\, 03 Nov 2009 10\:56\:02 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Eric W. Biederman a =C3=A9crit :
>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>> Very nice, with only one long line you could wrap differently.
>>=20
>> Say again?  Was that very nice with respect to the rest of the patch=
?
>> Or sarcasm because I overlooked this wrap at 80 columns
>> opportunity in ipgre?
>>=20
>> Eric
>>>  =20
>>>> -static int ipgre_newlink(struct net_device *dev, struct nlattr *t=
b[],
>>>> +static int ipgre_newlink(struct net *src_net, struct net_device *=
dev, struct nlattr *tb[],
>>>>  			 struct nlattr *data[])
>>>>  {
>>>>  	struct ip_tunnel *nt;
>
> Hmm, I am very sorry you take it as a sarcasm, I would not treat you =
or anyone like that.

I wasn't certain so I asked. You were sufficiently terse I wasn't certa=
in
what you meant.

> I was basically Acking your patch, with only one minor note about one=
 line becoming a bit long.
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> It would be better to write :
>
> static int ipgre_newlink(struct net *src_net, struct net_device *dev,
>   			 struct nlattr *tb[], struct nlattr *data[])

Agreed.

Eric


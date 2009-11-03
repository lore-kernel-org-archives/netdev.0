From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Support specifying the network namespace upon device
 creation.
Date: Tue, 03 Nov 2009 10:56:02 +0100
Message-ID: <4AEFFE32.4050808@gmail.com>
References: <m1eioggeux.fsf@fess.ebiederm.org> <4AEFF7BB.4090301@gmail.com> <m1ws28ey3k.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41807 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbZKCJ4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 04:56:00 -0500
In-Reply-To: <m1ws28ey3k.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman a =E9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> Very nice, with only one long line you could wrap differently.
>=20
> Say again?  Was that very nice with respect to the rest of the patch?
> Or sarcasm because I overlooked this wrap at 80 columns
> opportunity in ipgre?
>=20
> Eric
>>  =20
>>> -static int ipgre_newlink(struct net_device *dev, struct nlattr *tb=
[],
>>> +static int ipgre_newlink(struct net *src_net, struct net_device *d=
ev, struct nlattr *tb[],
>>>  			 struct nlattr *data[])
>>>  {
>>>  	struct ip_tunnel *nt;

Hmm, I am very sorry you take it as a sarcasm, I would not treat you or=
 anyone like that.

I was basically Acking your patch, with only one minor note about one l=
ine becoming a bit long.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

It would be better to write :

static int ipgre_newlink(struct net *src_net, struct net_device *dev,
  			 struct nlattr *tb[], struct nlattr *data[])




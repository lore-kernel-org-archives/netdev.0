From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Sun, 25 Oct 2009 11:09:49 +0200
Message-ID: <4AE415DD.5050406@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>	<1256115421-12714-9-git-send-email-gilad@codefidence.com>	<4ADED6FA.2030502@gmail.com>	<4ADEE119.7020803@codefidence.com>	<4ADF616B.1090405@gmail.com> <20091022003245.5cd4885c.billfink@mindspring.com> <4ADFE635.4020109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bill Fink <billfink@mindspring.com>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:57024 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbZJYJJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 05:09:49 -0400
In-Reply-To: <4ADFE635.4020109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


Eric Dumazet wrote:

> Bill Fink a =E9crit :
>
>  =20
>> And as mentioned previously, the global options can be quite useful
>> in certain test scenarios.  I also agree the per route settings are
>> a very useful addition.  I think the global and per route settings
>> are complementary and shouldn't be thought of as in conflict with
>> one another.
>>    =20
> Absolutely, global setting is a must when an admin wants a quick path=
=2E
>
> The more flexible would be to have two bits per route, plus
> 2 bits on the global configuration.
>
> global conf:
> 00 : timestamps OFF, unless a route setting is not 00
> 01 : timestamps ON, unless a route setting is not 00
> 10 : Force timestamps OFF, ignore route settings (emergency sysadmin =
request)
> 11 : Force timestamps ON, ignore route settings=20
>
> Route settings (used *only* if global setting is 0Y)
> 00 : global conf is used
> 01 : Force timestamps being OFF for this route
> 10 : Force timestamps being ON for this route
> 11 : complement global conf
> --
>  =20

Hey, I have no issue to re-spin the patch with this suggestion, if you=20
truly think this is valuable, but would you please consider the=20
nightmare of having to just explain this to someone?

It sounds to me way too complicated for what it does.

I still think having a global kill switch and per route options better=20
(basically use the exiting patch but not retire the global kill=20
switch|), but if you must Hgow about we leave the global sysctl as they=
=20
are and just have a two bit route option:

0 Use global default
1 Off
2 On

It's kind of funny, because this is what the original patch from=20
Comsleep does and I thought it needlessly complicates things.

So, what do you say - which will it be?

Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
=46ax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxolog=
y.net

	"Sorry cannot parse this, its too long to be true  :)"
	  -- Eric Dumazet on netdev mailing list


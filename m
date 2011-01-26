From: denys@visp.net.lb
Subject: Re: 40k+ outbound connections and bind() problem
Date: Wed, 26 Jan 2011 15:23:38 +0200
Message-ID: <398df9351d5c9aec1ba69511d9dc6a70@visp.net.lb>
References: <8cdb2dde69120a8668b31e2050916493@visp.net.lb>
 <AANLkTikSvf8bNK2_eHg+cWQJLz-56_88mrf0ttJX3W=0@mail.gmail.com>
 <9e62acde19ef75f3f77468cd81ed7ffd@visp.net.lb>
 <AANLkTinDQ-n3Y2_8PtvdWSxkYV8Kvj8on3iEeHsBSFB-@mail.gmail.com>
 <1296047834.2899.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Baluta <daniel.baluta@gmail.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:60382 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594Ab1AZNXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 08:23:50 -0500
In-Reply-To: <1296047834.2899.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Wed, 26 Jan 2011 14:17:14 +0100, Eric Dumazet wrote:
> Le mercredi 26 janvier 2011 =C3=A0 15:00 +0200, Daniel Baluta a =C3=A9=
crit :
>> Hi,
>>
>> > Latest stable, 2.6.37
>>
>> Please apply this patch [1] and see if it's still happening.
>>
>> thanks,
>> Daniel
>>
>> [1] http://www.spinics.net/lists/netdev/msg152204.html
>> -
>
> I dont think it'll help ;)
>
> Denys problem is if one source IP address is used, there is an=20
> absolute
> 64K limit to (IP, port) tuple
>
> Only thing you can do is to tune=20
> /proc/sys/net/ipv4/ip_local_port_range
> to get close to 64K limit
 No, it is not one ip source.
 As i mention before, i am binding each instance to different IP before=
=20
 connect().
 And when i am having issues and such errors, i am trying httping and=20
 binding it to some unused ip, but still getting this error.

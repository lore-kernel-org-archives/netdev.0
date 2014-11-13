From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN driver.
Date: Thu, 13 Nov 2014 19:57:50 +0400
Message-ID: <5464D4FE.4060006@parallels.com>
References: <1415744984-25802-1-git-send-email-maheshb@google.com> <546386AF.9030300@parallels.com> <CAF2d9jgRFZzjtEkwVqo5Jw1rzbAS_9NC8LiOtO6xHgWqkVM2Zg@mail.gmail.com> <546490E6.2050509@parallels.com> <CAF2d9jjmFymJdZmnfDCCUTRSSm-63RPaEFdB3TeYOq9S3jcPOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:39980 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbaKMQ7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 11:59:54 -0500
In-Reply-To: <CAF2d9jjmFymJdZmnfDCCUTRSSm-63RPaEFdB3TeYOq9S3jcPOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> Maybe introduce some "lock" call for ipvlan device after which no new IP addresses
>> can be assigned? And the configuration would look like
>>
>> 1. create ipvlan
>> 2. move to proper net namespace
>> 3. add addresses
>> 4. lock
>>
>> ?
> Yes. Exporting this "locked" property on the master device so that it
> can be controlled from masters' net-ns. Only thing we have to ensure
> is that both possibilities are allowed i.e. trusted ns where config do
> not need to be locked as well as untrusted/hostile ns where one can
> lock it down. However this is a future enhancement and if your
> implementation idea is different than this concept; we can discuss it
> at the time of implementation.

Sure. It's not a wish for the very first version of the set, it can
be added later.

Thanks,
Pavel

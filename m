From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Wed, 01 Apr 2015 12:58:50 +0300
Message-ID: <68621427882330@webcorp01g.yandex-team.ru>
References: <1427718657-21674-1-git-send-email-klamm@yandex-team.ru>
	<20150331.160538.1808487957641759931.davem@davemloft.net>
	<1427834148.979686.247747037.29964C1B@webmail.messagingengine.com> <20150331.164923.229749666073516444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150331.164923.229749666073516444.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

31.03.2015, 23:49, "David Miller" <davem@davemloft.net>:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 31 Mar 2015 22:35:48 +0200
>> =9ACould you quickly comment on what you had in mind? I guess it is =
about
>> =9Ahandling RA in user space on the end hosts and overwriting MTU du=
ring
>> =9Ainsertion of the routes?
>
> Even after reading your email I have no idea why you can't just have
> RA provide a 1500 byte MTU, everything else uses the device's 9000
> MTU, problem solved?

Because the MTU (provided by RA) is assigned to the device.

Thanks,
Roman

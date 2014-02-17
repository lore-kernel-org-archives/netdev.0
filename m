From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an anycast address
Date: Mon, 17 Feb 2014 11:42:45 -0800 (PST)
Message-ID: <1392666165.65245.YahooMailNeo@web125505.mail.ne1.yahoo.com>
References: <20140217.001545.981758741332832466.davem@davemloft.net>	<20140217093231.GA4609@cpaasch-mac>	<CAMrnHh5osKyOpmObYmWNswZuxYAc0SYUrmfohkg2GaafKmPK0w@mail.gmail.com> <20140217.141949.1387848185062797150.davem@davemloft.net>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm39.bullet.mail.ne1.yahoo.com ([98.138.229.32]:47874 "HELO
	nm39.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751847AbaBQTpn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 14:45:43 -0500
In-Reply-To: <20140217.141949.1387848185062797150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller <davem@davemloft.net>

> From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>>  On Mon, Feb 17, 2014 at 1:32 PM, Christoph Paasch
>>  <christoph.paasch@uclouvain.be> wrote:
>>>  I don't have strong opinions for or against this patch.
>>> 
>>>  I was only involved in the original thread because F-X claimed that
>>>  draft-iab-anycast-arch-implications (now RFC 7094) allows the use of 
> anycast
>>>  addresses for TCP, which is not what RFC 7094 is saying. There is no
>>>  recommendation concerning TCP in the RFC and the situation is rather 
> unclear.
>> 
>>  The same is here.
>> 
>>  Using anycast as source or bind address, why not?
>> 
>>  Use of anycast with TCP? Logically impossible, ergo prohibited.
>>  If someone wants to play with fire, the option can be left hidden behind
>>  a sysctl disabled by default.
> 
> Agreed.

If I understand well the reviews, no change was ask for this patch.
The sysctl was asked in case of patch for TCP.
So, why the status is now "Changes Requested" ? 

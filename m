From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: netfilter: synproxy iptables target
Date: Thu, 20 May 2010 16:25:17 +0200
Message-ID: <4BF5464D.4090409@trash.net>
References: <AANLkTimp6S7MpwDAT8l-M0ZWjs2HIcUEfL5f8j9-QDZh@mail.gmail.com> 	<4BF54310.6030004@trash.net> <AANLkTimjY_0yKfMtAUxI7He-QH5R5AdDCR3V8eKSgbGq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimjY_0yKfMtAUxI7He-QH5R5AdDCR3V8eKSgbGq@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changli Gao wrote:
> On Thu, May 20, 2010 at 10:11 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Changli Gao wrote:
>>> I have implemented a simple SYNPROXY iptables target. It is much like
>>> the SYNPROXY implementation in pf of OpenBSD, but won't have state
>>> until the first connection is established with the help of syncookies.
>>> The code is hosted at github:
>>>
>>> http://github.com/xiaosuo/xiaosuo/tree/master/synproxy/
>>>
>>> Currently, it can work with firewall and local socket.
>>>
>>> It is in the very early stage, and ugly. And I will add --timeout
>>> parameter to this target as TCP_DFER_ACCEPT, so I can do NAT basing on
>>> the request data.
>>>
>>> i.e.
>>>
>>> iptables -t nat -A OUTPUT -p tcp -m synproxy --http-url "*.jpg" -j
>>> DNAT --to-destination $image_http_server:80
>>>
>>> And is there any chance to merge it into mainline?
>> If you can state a good use case, sure. I don't know much about the
>> PF synproxy myself.
>>
> 
> pure synproxy can be used on firewall to protect the internal servers,
> which don't support neither syncookies and synproxy, from the attack
> of SYN-flood.
> 
> synproxy with defered connection relay acts as a layer 7 proxy, but
> works in kernel space totally, unlike tcp splice tech., which needs
> the applications in user space parse the requests, and establish the
> connections.

I can't say much before seeing any code, but no general objections
from my side.

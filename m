From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback connections
Date: Thu, 20 Sep 2012 10:24:36 -0700
Message-ID: <505B5154.3020002@hp.com>
References: <1347908305-13541-1-git-send-email-brutus@google.com> <1347913239.26523.173.camel@edumazet-glaptop> <20120919.163406.487082174277409074.davem@davemloft.net> <1348088634.31352.26.camel@edumazet-glaptop> <CAEkNxbEJjAu3+3yDGPGSzzee-LY_797RdNbBgcC6=-aDHfEAJQ@mail.gmail.com> <505AFDE9.4080602@earthlink.net> <1348141871.31352.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sclark46@earthlink.net, Bruce Curtis <brutus@google.com>,
	David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:46149 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab2ITRYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 13:24:37 -0400
In-Reply-To: <1348141871.31352.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2012 04:51 AM, Eric Dumazet wrote:
> On Thu, 2012-09-20 at 07:28 -0400, Stephen Clark wrote:
>>
>> Does this mean traffic on the loopback interface will not traverse
>> netfilter?
>>
>
> Yes this was already mentioned.
>
> Only the SYN / SYNACK messages will
>
> All data will bypass IP stack, qdisc (if any), loopback driver, and
> netfilter.

Does that then lift the tent flap for TOE?  As I recall, TOE's bypassing 
of all those things is one of the reasons used to reject TOE.

rick jones

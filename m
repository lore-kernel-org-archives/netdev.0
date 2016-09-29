From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net v2] L2TP:Adjust intf MTU,factor underlay L3,overlay L2
Date: Thu, 29 Sep 2016 16:39:21 +0100
Message-ID: <57ED35A9.7080604@katalix.com>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net>
 <20160927.033153.1066118008027608891.davem@davemloft.net>
 <alpine.DEB.2.11.1609271210350.25517@duvvury48.eng.vyatta.net>
 <20160928.034841.997752666320557327.davem@davemloft.net>
 <alpine.DEB.2.11.1609281857050.17015@duvvury48.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, kleptog@svana.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        nprachan@brocade.com, rshearma@brocade.com, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com
To: "R. Parameswaran" <parameswaran.r7@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49243 "EHLO mail.katalix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754474AbcI2Pjd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 11:39:33 -0400
In-Reply-To: <alpine.DEB.2.11.1609281857050.17015@duvvury48.eng.vyatta.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/09/16 03:36, R. Parameswaran wrote:
> I agree that something like 2. below would be needed in the long run (it 
> will need some effort and redesign -e.g. how do I lookup the parent tunnel 
> from the socket when receiving a PMTU update, existing pointer chain runs 
> from tunnel to socket).
>> 2) Add code to handle PMTU events that land on the UDP tunnel
>>    socket.

Another function pointer could be added to struct udp_sock, similar to
encap_rcv,  such that the pmtu event could be handled by the UDP encap
protocol implementation.

James

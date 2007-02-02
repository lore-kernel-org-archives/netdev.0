From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: sky2 hangs
Date: Fri, 2 Feb 2007 14:43:11 +0100
Message-ID: <20070202134311.GA1643@ff.dom.local>
References: <45C32654.3060602@conceptonline.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Glanzmann <thomas@glanzmann.de>,
	Julien BLACHE <jb@jblache.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Fagyal Csongor <concept@conceptonline.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:49541 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161126AbXBBNk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 08:40:27 -0500
Content-Disposition: inline
In-Reply-To: <45C32654.3060602@conceptonline.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02-02-2007 12:53, Fagyal Csongor wrote:
> Thomas Glanzmann wrote:
...
>>> Next time sky2 hangs on me I'll try to reset the PHY and see if that
>>> helps. I can usually trigger the hang by doing a couple of ifconfig
>>> up/down on the interface, though I'm not getting any error message
>>> from the driver when that happens.
>>>   
>>
>> same for me. In dmesg is absolut nothing. I change my fix script, too.
>> To see if that is enough to resolv the problem.
>>  
>>
> Well, ethtool -r eth0 did not work for me. :(
> 
> This time I got nothing in the log.
> 
> When I say ethtool -r eth0, I have this:
> sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control both
> 
> But the interface stays down. (Maybe the other end got confused?)

Hi,

Is this with this yesterday sky2-tx-recover.patch applied?

Jarek P.

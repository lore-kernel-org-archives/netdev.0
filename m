From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 09 May 2008 15:09:37 -0700
Message-ID: <4824CBA1.8040703@sun.com>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>
 <20080507.141521.193714938.davem@davemloft.net> <482498D5.9060008@krogh.cc>
 <20080509.143229.174354251.davem@davemloft.net> <4824C936.9000103@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:33029 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794AbYEIWJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:09:39 -0400
In-reply-to: <4824C936.9000103@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:
> David Miller wrote:
>> From: Jesper Krogh <jesper@krogh.cc>
>> Date: Fri, 09 May 2008 20:32:53 +0200
>>
>>> When it works I doesnt seem to be able to get it pass 500MB/s.
>>
>> With this card you really need multiple cpus and multiple threads
>> sending data through the card in order to fill the 10Gb pipe.
>>
>> Single connections will not fill the pipe.
> 
> The server is a Sun X4600 with 8 x dual-core CPU's, setup with 64
> NFS-threads. The other end of the fiber goes into a switch with gigabit
> ports connected to 48 dual-core cpus. The test was done doing a dd on a
> 4.5GB file from the server to /dev/null on the clients.

Are you doing a TX or RX (with respect to the 10G if)?
-- matheos

> 
> The number of contextswitches seems enourmous.. over 120.000 sometimes.
> When transmitting around the same amount of data (4xgigabit bonded with
> 802.3ad) 4x110MB/s the amount of contextswitches only reaches 3-4.000. I
> have no idea if this has any relevance.
> 
> Should this setup not be able to fill the pipe?
> 


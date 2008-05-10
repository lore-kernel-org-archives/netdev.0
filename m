From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Sat, 10 May 2008 13:01:08 +0200
Message-ID: <48258074.7060306@krogh.cc>
References: <4821F3B7.2090702@krogh.cc>	<86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com> <20080507.141521.193714938.davem@davemloft.net> <482498D5.9060008@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:53432 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914AbYEJLBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 May 2008 07:01:14 -0400
In-Reply-To: <482498D5.9060008@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:
> David Miller wrote:
>> From: "Yinghai Lu" <yhlu.kernel@gmail.com>
>> Date: Wed, 7 May 2008 11:30:18 -0700
>>
>>> On Wed, May 7, 2008 at 11:23 AM, Jesper Krogh <jesper@krogh.cc> wrote:
>>>> Hi.
>>>>
>>>>  I get errors like this after a few minutes of traffic on a Sun 
>>>> Neptune 10g
>>>> ethernet card. (with nice 500MB/s throughput).
>>>>
>>>>  Then the server seems too busy with something, so it doesn't even 
>>>> respont
>>>> to a serial terminal login.
>>>>
>>>>  May  7 16:16:33 hest kernel: [  166.948958] niu: niu_get_parent:
>>>> platform_type[1] port[3]
>>>>  May  7 16:16:33 hest kernel: [  166.949366] niu: 
>>>> niu_get_and_validate_port:
>>>> port[3] num_ports[2]
>>>>  May  7 16:16:33 hest kernel: [  166.949886] niu: niu_put_parent: 
>>>> port[3]
>>>>  .. bootup ends here ..
>>>>  May  7 17:13:54 hest kernel: [ 3670.128178] niu 0000:84:00.0: niu: 
>>>> eth4:
>>>> Transmit timed out, resetting
>>>>  May  7 17:14:04 hest kernel: [ 3680.108614] niu 0000:84:00.0: niu: 
>>>> eth4:
>>>> Transmit timed out, resetting
>>>>  May  7 17:14:14 hest kernel: [ 3690.093089] niu 0000:84:00.0: niu: 
>>>> eth4:
>>>> Transmit timed out, resetting
>>>>  May  7 17:14:19 hest kernel: [ 3695.079254] niu 0000:84:00.0: niu: 
>>>> eth4:
>>>> Transmit timed out, resetting
>>>>  May  7 17:14:24 hest kernel: [ 3700.073525] niu 0000:84:00.0: niu: 
>>>> eth4:
>>>> Transmit timed out, resetting
>>>>  May  7 17:14:29 hest kernel: [ 3705.063744] niu 0000:84:00.0: niu: 
>>>> eth4:
>>>> Transmit timed out, resetting
>>>>  May  7 17:14:34 hest kernel: [ 3710.049918] niu 0000:84:00.0: niu: 
>>>> eth4:
>>>> Transmit timed out, resetting
>>>>
>>>>
>>>>  Any suggestions?
>>>>
>>>>  The system is an Ubuntu Hardy (2.6.24-17-server) amd64.
>>> can you try 2.6.25 or current git?
>>
>> Also, please always CC: netdev@vger.kernel.org on networking reports.
> 
> Yes. It is reproducable under 2.6.25.2, when the load get up.. (worked 
> excellent in the <100MB/s range for several hours.

Any good suggestions about the "Transmit timed out" messages. It
currently leads to a system that "doesnt die" but doesnt respond within
15 minutes of load of the network adapter.

Does the high amount of Context-switches (120.000+ have any influence)?

Should I be able to use TSO?
# ethtool -k eth4
Offload parameters for eth4:
Cannot get device rx csum settings: Operation not supported
rx-checksumming: off
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off

ethtool v6

Jesper
-- 
Jesper

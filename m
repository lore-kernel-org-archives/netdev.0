From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 29 Sep 2014 12:48:19 -0700
Message-ID: <5429B783.20207@candelatech.com>
References: <52EFFE20.5080500@candelatech.com>  <20140203220323.GB17999@order.stressinduktion.org>  <52F012FF.9030105@candelatech.com> <52F65EB4.1050306@candelatech.com>  <20140208172310.GF16198@order.stressinduktion.org>  <loom.20140926T001736-777@post.gmane.org>  <1411906297.2400343.172598909.66223582@webmail.messagingengine.com>  <loom.20140929T195637-887@post.gmane.org>  <5429A886.1040809@candelatech.com> <1412017399.14757.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Hongmei Li <duckcncn@gmail.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:52340 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbaI2TsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:48:20 -0400
In-Reply-To: <1412017399.14757.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2014 12:03 PM, Hannes Frederic Sowa wrote:
> On Mo, 2014-09-29 at 11:44 -0700, Ben Greear wrote:
>> On 09/29/2014 11:15 AM, Hongmei Li wrote:
>>> Thanks Hannes for your prompt response!
>>>
>>> We just encountered this issue two times in our product stability test so far,
>>> and my panic backtrace is the exactly same with the one reported here.
>>> I don't know how to reproduce the issue till now. 
>>> I tried several method, unfortunately, I can not reproduce it by myself. :(
>>
>> We could reproduce it easily using our user-space tool that creates 1000
>> mac-vlans, configures them, dumps routing tables, etc.  But, we could
>> only reproduce it when we had the ixgbe ports unplugged.  If they
>> were properly connected to a switch, we did not see any crashes.
>>
>> My original email on 2/3/2014 has more details, and the thread that
>> follows has some info on debugging we did at the time.
> 
> I just tried to reproduce the problem, disabling the port on a switch
> and setting up 1000 macvlans on a ixgbe, enabling ipv6 and dumping
> routing tables. Unluckily I had no success. :(
> 
> Any more hints?

We are going to be running up to 20 concurrent scripts that
will be dumping routes & ips, and configuring ip addresses
and routes during bringup.

I don't have a simple stand-alone way to reproduce this,
but at least when we reported the problem is was very easy
for us to reproduce with our tool.

Maybe 20 scripts running in parallel that randomly configured and dumped routes
and ip addresses on random interfaces would do the trick?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

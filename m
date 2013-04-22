From: Mark Jackson <mpfj-list@newflow.co.uk>
Subject: Re: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Mon, 22 Apr 2013 15:07:35 +0100
Message-ID: <51754427.7000908@newflow.co.uk>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com> <516B0098.4040809@mimc.co.uk> <516C33D2.4050105@ti.com> <516C38B9.50904@mimc.co.uk> <516C3A0D.70903@ti.com> <517018E6.6080108@newflow.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercuryimc.plus.com ([80.229.200.144]:44965 "EHLO
	centos1.newflow.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751827Ab3DVOHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 10:07:40 -0400
In-Reply-To: <517018E6.6080108@newflow.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/04/13 17:01, Mark Jackson wrote:
> On 15/04/13 18:34, Mugunthan V N wrote:
>> On 4/15/2013 10:58 PM, Mark Jackson wrote:
>>> On 15/04/13 18:07, Mugunthan V N wrote:
>>>> On 4/15/2013 12:46 AM, Mark Jackson wrote:
>>>
>>> <snip>
>>>
>>>>>
>>>>> Notice that at the end, the nfs link appears to come back "ok", but
>>>>> the "ps" command never completes.
>>>>>
>>>>> Any ideas of what's going on ?
>>>>
>>>> I have tried ping on both the interface fine. Will verify with ps again
>>>> later in this week.
>>>> Can you provide below details details
>>>> - Are you using EVMsk or custom build EVM?
>>>
>>> This is a custom board (based on the BeagleBone design) with dual
>>> Ethernet, NAND, NOR and FRAM.
>>>
>>> The dual emac thing is (one of) the last things to get signed off, so
>>> I'm willing to assist in tracking this down.
>>
>> After testing the scenario i may be able to send you an update later in
>> this week.
> 
> I have made some progress ... I realised I was missing a (clearly rather
> important !!) item in my .config file, namely CONFIG_TI_DAVINCI_EMAC.
> 
> I am now able to ping from our board to other systems on the network
> (again, I've only tested eth0 at the moment).
> 
> However, I am unable to ping everything I should be able to !!

<snip>

> When the pings fail, I am unable to see *any* activity on the network
> (using wireshark).
> 
> Is there anything else I should try ?

Mugunthan

Can you confirm that I'm actually trying to achieve the right thing ?

I have all along assumed that Dual EMAC mode would simply provide the
kernel will a pair of independent Ethernet ports.

All I am trying to do is to get both Ethernet ports working so I can
have one port on (say) 10.0.x.x and the other on (say) 10.1.x.x

But there is all this reference to VLANs(in the source code and the TRM)
... I have not setup any VLANs.  Do I need to ?  If so, how ?

Cheers
Mark J.

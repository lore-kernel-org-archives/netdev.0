From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [linux-4.4-mw] BUG: unable to handle kernel paging request
 =?UTF-8?Q?ip=5Fvs=5Fout=2Econstprop?=
Date: Thu, 12 Nov 2015 18:12:03 +0100
Message-ID: <fef480295a9499b1990ca881316516d6@eikelenboom.it>
References: <06dc952f98f54da2c4d85b31e5fa9826@eikelenboom.it>
 <1447337353.22599.14.camel@edumazet-glaptop2.roam.corp.google.com>
 <b95f4a06d7d9b13849ad277128690436@eikelenboom.it>
 <1447347146.22599.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:57806 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802AbbKLROR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 12:14:17 -0500
In-Reply-To: <1447347146.22599.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-11-12 17:52, Eric Dumazet wrote:
> On Thu, 2015-11-12 at 16:16 +0100, Sander Eikelenboom wrote:
> 
>> > Thanks for the report, please try following patch :
>> 
>> Hi Eric,
>> 
>> Thanks for the patch!
>> Got it up and running at the moment, but since i don't have a clear
>> trigger it
>> will take 1 or 2 days before i can report something back.
> 
> Don't worry, I have a pretty good picture of the bug and patch must fix
> it.
> 
> I'll submit it formally asap.

Ok.

Do you know were these new warnings are for ?
(apparently all networking including bridging works fine, so is this 
just too verbose logging ?)

[  207.033768] vif vif-1-0 vif1.0: set_features() failed (-1); wanted
0x0000000400004803, left 0x0000000400114813
[  207.033780] vif vif-1-0 vif1.0: set_features() failed (-1); wanted
0x0000000400004803, left 0x0000000400114813
[  207.245435] xen_bridge: error setting offload STP state on port
1(vif1.0)
[  207.245442] vif vif-1-0 vif1.0: failed to set HW ageing time
[  207.245443] xen_bridge: error setting offload STP state on port
1(vif1.0)
[  207.245491] vif vif-1-0 vif1.0: set_features() failed (-1); wanted
0x0000000400004803, left 0x0000000400114813

--
Sander

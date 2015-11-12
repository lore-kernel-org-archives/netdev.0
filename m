From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [linux-4.4-mw] BUG: unable to handle kernel paging request
 ip_vs_out.constprop
Date: Thu, 12 Nov 2015 22:39:47 +0200
Message-ID: <20151112203947.GA8113@colbert.Home>
References: <06dc952f98f54da2c4d85b31e5fa9826@eikelenboom.it>
 <1447337353.22599.14.camel@edumazet-glaptop2.roam.corp.google.com>
 <b95f4a06d7d9b13849ad277128690436@eikelenboom.it>
 <1447347146.22599.22.camel@edumazet-glaptop2.roam.corp.google.com>
 <fef480295a9499b1990ca881316516d6@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0064.outbound.protection.outlook.com ([157.56.112.64]:22701
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751035AbbKLUj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 15:39:56 -0500
Content-Disposition: inline
In-Reply-To: <fef480295a9499b1990ca881316516d6@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 12, 2015 at 07:12:03PM IST, linux@eikelenboom.it wrote:
>On 2015-11-12 17:52, Eric Dumazet wrote:
>> On Thu, 2015-11-12 at 16:16 +0100, Sander Eikelenboom wrote:
>> 
>>> > Thanks for the report, please try following patch :
>>> 
>>> Hi Eric,
>>> 
>>> Thanks for the patch!
>>> Got it up and running at the moment, but since i don't have a clear
>>> trigger it
>>> will take 1 or 2 days before i can report something back.
>> 
>> Don't worry, I have a pretty good picture of the bug and patch must fix
>> it.
>> 
>> I'll submit it formally asap.
>
>Ok.
>
>Do you know were these new warnings are for ?
>(apparently all networking including bridging works fine, so is this 
>just too verbose logging ?)

Yes, I think I do. I can send a patch tomorrow morning unless someone
beats me to it.

Thanks for reporting!

>
>[  207.033768] vif vif-1-0 vif1.0: set_features() failed (-1); wanted
>0x0000000400004803, left 0x0000000400114813
>[  207.033780] vif vif-1-0 vif1.0: set_features() failed (-1); wanted
>0x0000000400004803, left 0x0000000400114813
>[  207.245435] xen_bridge: error setting offload STP state on port
>1(vif1.0)
>[  207.245442] vif vif-1-0 vif1.0: failed to set HW ageing time
>[  207.245443] xen_bridge: error setting offload STP state on port
>1(vif1.0)
>[  207.245491] vif vif-1-0 vif1.0: set_features() failed (-1); wanted
>0x0000000400004803, left 0x0000000400114813
>
>--
>Sander
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

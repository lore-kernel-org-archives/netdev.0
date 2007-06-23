From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 23 Jun 2007 14:05:43 +0200
Message-ID: <467D0C97.1000000@hartkopp.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de> <467BC2AF.8080901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, j.hadi123@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:64703 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbXFWMG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 08:06:26 -0400
In-Reply-To: <467BC2AF.8080901@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Urs Thuermann wrote:
>   
>> Patrick McHardy <kaber@trash.net> writes:
>>
>>
>>     
>>> Is there a reason why you're still doing the "allocate n devices
>>> on init" thing instead of using the rtnl_link API?
>>>       
>> Sorry, it's simply a matter of time.  We have been extremely busy with
>> other projects and two presentations (mgmt, customers, and press) the
>> last two weeks and have worked on the other changes this week.  I'm
>> sorry I haven't yet been able to look at your rtnl_link code close
>> enough, but it's definitely on my todo list.  Starting on Sunday I'll
>> be on a business trip to .jp for a week, and I hope I get to it in
>> that week, otherwise on return.
>>     
>
>
> Sorry, but busy is no reason for merging code that has deprecated
> (at least by me :)) behaviour. Please change this before submitting
> for inclusion.
>   

Dear Patrick,

i was just looking through the mailings regarding your suggested changes
(e.g. in VLAN, DUMMY and IFB) an none of them currently went into the
kernel and the discussion on some topics (especially in the VLAN case)
is just running.

I just got an impression of what you intend to have and it looks
reasonable and good to me. But anyhow it's in process and therefore i
won't like to be the first adopter as you might comprehend. It is no
question, that we would update to your approach as it is part of the
kernel, finalized in discussion and somewhat stable. But it doesn't look
adequate to me to push us to support your brand new approach as some
kind of gate for an inclusion into the mainstream kernel :-(

So for me it looks like, that we should get the feedback from Jamal if
our usage of skb->iif fits the intention of skb->iif and if we should
set the incoming interface index ourselves of if we let
netif_receive_skb() do this job. After that discussion i currently can
not see any reason, why the PF_CAN support should not go into the
mainstream kernel. I daily get positive community feedback about this
matching implementation for the Linux kernel and it's elegant manner of
usage for application programmers.

On our TODO list there is the netlink support as well as the usage of
hrtimers in our broadcast manager - but both have no vital influence to
the new protocol family PF_CAN and therefore it should not slow down the
inclusion process. Be sure that we'll support netlink immediately, when
it hits the road for other drivers also.

Best regards,
Oliver



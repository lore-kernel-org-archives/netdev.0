From: Simon Barber <simon@superduper.net>
Subject: Re: [Bridge] VLANs and bridge
Date: Sat, 22 Aug 2009 10:12:10 -0700
Message-ID: <4A9026EA.9020404@superduper.net>
References: <OFC5BA9A4A.DCCE8D0D-ONC125761A.004A7620-C125761A.004BEA17@transmode.se> <4A9001E3.6060506@superduper.net> <OF2C06F138.1BC279AE-ONC125761A.0054117B-C125761A.0055C6F1@LocalDomain> <OF9BD07CB5.A2197AEA-ONC125761A.005AE004-C125761A.005B662E@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from masada.superduper.net ([85.133.44.198]:52296 "EHLO
	masada.superduper.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932665AbZHVQwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2009 12:52:05 -0400
In-Reply-To: <OF9BD07CB5.A2197AEA-ONC125761A.005AE004-C125761A.005B662E@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking through B.1.3 it looks like the patch would need some 
enhancement. It provides a good basis - handling tagging/untagging and 
filtering, but would need a way to specify the untagged vlan separately 
for in and out.

Simon


Joakim Tjernlund wrote:
> Joakim Tjernlund/Transmode wrote on 22/08/2009 17:36:54:
>   
>> Simon Barber <simon@superduper.net> wrote on 22/08/2009 16:34:11:
>>     
>>> Hi Joakim,
>>>
>>> Look back a month or so in the archives - you'll find an email from me
>>> referencing a patch to make the bridge VLAN aware. It's a little old,
>>> and needs updating for 2.6 (it was written for 2.4) - but should not be
>>> much work to get it done. There is a matching patch for the brctl utility.
>>>
>>> Simon
>>>
>>>       
>> Thanks Simon
>>
>> Do you mean the "bridge vlan integration" patch?
>> It is not clear to me if this would support the case
>> described in B.1.3(802.1Q-2005), does it?
>>
>> Seems like there is little interest to post this to 2.6 and
>> I am not sure how welcome this would be either, perhaps
>> the bridge maintainer could comment?
>>
>>   Jocke
>>     
>
> Thinking a bit more about this I could envision some changes to the
> vlan code too. I image one could create one vlan interface which will listen
> to several VLANs. One VLAN is the primary VLAN and is used in the tx path
> by default. The bridge would be able to filter on individual VLANs received
> from such interface and be able to chose outgoing VLAN too.
>
>  Jocke
>
>   


From: Patrick McHardy <kaber@trash.net>
Subject: Re: net: fix network drivers ndo_start_xmit() return values
Date: Tue, 16 Jun 2009 11:49:48 +0200
Message-ID: <4A376ABC.2020303@trash.net>
References: <4A367E14.4040104@trash.net> <20090616061603.GA4494@ff.dom.local> <20090616071204.GB4494@ff.dom.local> <4A376665.6000801@trash.net> <20090616094608.GB6106@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, perex@perex.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34376 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbZFPJts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:49:48 -0400
In-Reply-To: <20090616094608.GB6106@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Jun 16, 2009 at 11:31:17AM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> On Tue, Jun 16, 2009 at 06:16:03AM +0000, Jarek Poplawski wrote:
>>>   
>>>> On 15-06-2009 19:00, Patrick McHardy wrote:
>>>>     
>>>>> This patch contains the final driver ndo_start_xmit() return
>>>>> value fixups. I'm pretty sure I got them all ...
>>>>>       
>>> ...You should probably revisit wireless/zd1201.c (return 0) btw.
>> Whats wrong with that?
> 
> I thought you wanted to replace it with NETDEV_TX_OK, but now I see
> you leave both variants in the last patch, so I'm not sure...

I wanted to do that in a seperate patch at the end of the merge
window to avoid causing too much clashes with this (and catch
any new drivers).

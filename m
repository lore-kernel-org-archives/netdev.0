From: Patrick McHardy <kaber@trash.net>
Subject: Re: Wrong padding of short packets send by a tagged-vlan interface?
Date: Mon, 07 Jul 2008 23:12:31 +0200
Message-ID: <487286BF.5040407@trash.net>
References: <Pine.LNX.4.64.0807072210470.15459@bizon.gios.gov.pl> <4872854F.80603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38725 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756622AbYGGVMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:12:34 -0400
In-Reply-To: <4872854F.80603@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Krzysztof Oledzki wrote:
>> Hello,
>>
>> I have a problem that I'm not able to connect from selected linux 
>> hosts to a newly installed Netware 6.5 server. After two days of 
>> debugging I discovered that the problem seems to be caused by an 
>> insufficient padding of a .1q tagged packets.
> 
> Last time this came up I looked up the RFC and according to it
> there is no need to pad beyond the normal 60 + 4, vlan tag or
> not.
> 
> This is a bug in your intervening switch and/or Netware unless you 
> actually see packets
> leaving Linux with less than 60 + 4 bytes.

Yes, its probably not on the Linux side. It would be interesting
to know where exactly the bug is happening though.

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] be2net: Adding support for 802.1ad (q-in-q mode)
Date: Thu, 23 Jul 2009 11:07:23 +0200
Message-ID: <4A68284B.8020100@trash.net>
References: <20090723082552.GA602@serverengines.com> <4A6823B5.7050608@trash.net> <20090723090216.GA1761@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63422 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbZGWJH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 05:07:27 -0400
In-Reply-To: <20090723090216.GA1761@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sarveshwar Bandi wrote:
> On 23/07/09 10:47 +0200, Patrick McHardy wrote:
>> Sarveshwar Bandi wrote:
>>> Please review and apply patch to net-next tree. Patch implements the 
>>> support for q-in-q mode.
>>
>> Please describe your change more precisely. How does this interact with
>> the stack and which VID is propagated to the VLAN code?
>
> Patch has code to check if the controller is in q-in-q mode. When the packet
> has two vids, only the inner vid is passed onto the stack. The stack is never
> made aware of the outer vid.

But you're still using the outer VLAN group when passing the packet to
the VLAN code, so the association to the correct VLAN device can't work.

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Tue, 07 Oct 2008 01:04:33 +0200
Message-ID: <48EA9981.1020109@trash.net>
References: <20081006173024.2741cc01@speedy>	<48EA369F.3090306@trash.net>	<20081006195446.1dc5a372@speedy> <48EA9223.8090700@trash.net> <48EA964A.6060503@hp.com> <48EA98F0.40302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56883 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbYJFXEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 19:04:40 -0400
In-Reply-To: <48EA98F0.40302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Rick Jones wrote:
>> If physical interface MTUs are going to be bouncing around and VLANs 
>> get their MTUs changed then perhaps a VLAN needs both a desired and 
>> actual MTU setting.  The VLAN's interface would then be the minimum of 
>> the desired and actual MTU.  I suppose it isn't too unlike having both 
>> an administrative (desired) and operational (actual) interface state.
> 
> Thats assuming that the VLAN device is actually restricted by the
> ethernet device settings. I don't know if its always not the case,
> but I'm pretty sure it usually isn't. Which means there's no real
> need for an operational state wrt. MTUs.

Actually it would be useful to have this kind of information on the
*ethernet* device to specify the upper limit.

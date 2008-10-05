From: Patrick McHardy <kaber@trash.net>
Subject: Re: 802.1p, skb->priority, CoS for transit traffic not working?
Date: Sun, 05 Oct 2008 18:56:03 +0200
Message-ID: <48E8F1A3.3070900@trash.net>
References: <200810051935.56616.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49289 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbYJEQ4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 12:56:09 -0400
In-Reply-To: <200810051935.56616.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> I'm trying to set CoS tag, to manage priorities on my microwave link.
> Possible such setup will be very useful also to set classify traffic passing 
> QoS. A lot of hardware support this simple L2 QoS.
> 
> [...]
> Is there a way to make work changing transit packets 802.1p values?

Bridging traffic to a VLAN device should work, you can then
define the priority for the device. I'm not aware of an easier
method, but I believe act_pedit should also be able to do this.

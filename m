From: Patrick McHardy <kaber@trash.net>
Subject: Re: port bound SAs
Date: Tue, 27 Jan 2009 18:01:04 +0100
Message-ID: <497F3DD0.5010502@trash.net>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net> <497EE171.1030907@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42197 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175AbZA0RBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:01:08 -0500
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore wrote:
> racoon
> 
> if I look at the xfrm/pfkey code in the kernel it ignores any ports sent
> down by the IKE daemon in transport mode. I actually changed the racoon
> code to include the ports and it makes no difference

Assuming you're also using setkey, try adding "unique" to your policies.


From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 9/11][INET] Merge sys.net.ipv4.ip_forward
 and sys.net.ipv4.conf.all.forwarding
Date: Wed, 05 Dec 2007 01:45:11 -0800 (PST)
Message-ID: <20071205.014511.58357775.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<475528BC.1010505@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38349
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751982AbXLEJpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:45:12 -0500
In-Reply-To: <475528BC.1010505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:15:24 +0300

> AFAIS these two entries should do the same thing - change the
> forwarding state on ipv4_devconf and on all the devices.
> 
> I propose to merge the handlers together using ctl paths.
> 
> The inet_forward_change() is static after this and I move
> it higher to be closer to other "propagation" helpers and
> to avoid diff making patches based on { and } matching :)
> i.e. - make them easier to read.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I agree with your analysis and patch, applied.

Thanks.

From: Patrick McHardy <kaber@trash.net>
Subject: Re: Action 4 device ifb0 ifindex 7
Date: Thu, 23 Nov 2006 11:24:34 +0100
Message-ID: <456576E2.2060902@trash.net>
References: <BAY103-DAV1480D024D2786617F99E92B2E20@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45460 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1757334AbWKWKYh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 05:24:37 -0500
To: Marco Berizzi <pupilla@hotmail.com>
In-Reply-To: <BAY103-DAV1480D024D2786617F99E92B2E20@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi wrote:
> Hi everybody.
> I'm receiving this message:
> 
> Action 4 device ifb0 ifindex 7
> 
> when I issue this command:
> 
> tc filter add dev eth1 parent ffff: protocol ip prio 1 u32 \
> match u32 0 0 action mirred egress redirect dev ifb0
> 
> I'm using linux 2.6.19-rc6 with tc version ss061002
> Am I missing anything?


Thats debugging output from tc actions. I guess its time to
remove them or at least shut them up.

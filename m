From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v4 1/3] net: TCP thin-stream detection
Date: Mon, 22 Feb 2010 14:13:06 -0800 (PST)
Message-ID: <20100222.141306.77019816.davem@davemloft.net>
References: <20100221.150311.193707249.davem@davemloft.net>
	<FB5F656F-091A-4FB5-9586-15C6CB263D05@nokia.com>
	<87k4u5mh9u.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.eggert@nokia.com, zimmermann@nets.rwth-aachen.de,
	pavel@ucw.cz, apetlund@simula.no, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, eric.dumazet@gmail.com,
	Arnd.Hannemann@nets.rwth-aachen.de, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, william.allen.simpson@gmail.com,
	damian@tvk.rwth-aachen.de, ebiederm@xmission.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33132
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754440Ab0BVWMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 17:12:50 -0500
In-Reply-To: <87k4u5mh9u.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 22 Feb 2010 16:17:33 +0100

> Lars Eggert <lars.eggert@nokia.com> writes:
> 
>> If it's off by default there is no issue.
> 
> Still a sufficient large number of people might turn it on
> and then the network would melt.

And they can do the same by changing the initial congestion window
setting, which we also support.

The foundation of your argument is as solid as quicksand.

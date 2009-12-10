From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
 window.
Date: Wed, 09 Dec 2009 18:21:31 -0800 (PST)
Message-ID: <20091209.182131.226771813.davem@davemloft.net>
References: <pvm638hum1a.fsf@chavey.mtv.corp.google.com>
	<87fx7kmg6o.fsf@basil.nowhere.org>
	<65634d660912091001s44016cccq4f2422e613ba9db9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, chavey@google.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54898
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759472AbZLJCV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 21:21:26 -0500
In-Reply-To: <65634d660912091001s44016cccq4f2422e613ba9db9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 9 Dec 2009 10:01:24 -0800

> If we can use larger initial congestion windows on private networks
> that we know to be

With the keyword here being "network", which is why this must be a
route attribute not a sysctl with global unilatteral effect.

Otherwise I can tell you what people with both forward and inward
facing interfaces are going to do, they'll turn the thing on globally
with your sysctl even though they process real Internet traffic.

No way, we're not going to make it so easy to screw things up.

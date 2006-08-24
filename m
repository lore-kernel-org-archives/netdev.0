From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev 4/6] d80211: Send Layer 2 Update frames in
 kernel
Date: Thu, 24 Aug 2006 13:36:29 +0200
Message-ID: <20060824133629.7b553d88@griffin.suse.cz>
References: <20060807231608.888744720@localhost>
	<20060807231938.455373487@localhost>
	<20060823192256.3e8df7f9@griffin.suse.cz>
	<200608232350.41963.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:20691 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751155AbWHXLgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 07:36:31 -0400
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200608232350.41963.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006 23:50:41 +0200, Stefan Rompf wrote:
> Imagine an ESS consisting of several APs in a switched wired network. Client 
> roams from one AP to another. In order to update the FDB of the switches, a 
> packet with the client MAC address needs to be originated from the ethernet 
> interface of the AP the client has associated to, even if the client does not 
> create traffic at the moment.

Thanks for the explanation! I didn't thought about ESS when looking at
that patch.

If I understand it right, it's not necessary to send the XID Update
frame for each added STA. Shouldn't there be a flag indicating if the
frame needs to be send? Userspace knows that information.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs

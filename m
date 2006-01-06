From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Bcm43xx-dev] [Fwd: State of the Union: Wireless]
Date: Fri, 06 Jan 2006 09:02:42 -0800
Message-ID: <43BEA2B2.7060104@candelatech.com>
References: <1136541243.4037.18.camel@localhost> <200601061200.59376.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752480AbWAFRDY@vger.kernel.org>
To: Michael Buesch <mbuesch@freenet.de>
In-Reply-To: <200601061200.59376.mbuesch@freenet.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:

> How would the virtual interfaces look like? That is quite easy to answer.
> They are net_devices, as they transfer data.
> They should probaly _not_ be on top of the ethernet, as 80211 does not
> have very much in common with ethernet. Basically they share the same
> MAC address format. Does someone have another thing, which he thinks
> is shared?

If you can make the virtual devices look like ethernet, I believe a lot of other things
will just work w/out hacking, including user-space apps that think they
know exactly what an ethernet frame/device looks like.

The only things I think of that won't work like ethernet is the ability to
change the local MAC address or go into promisc mode.  And, it's always possible
that future wifi hardware will support that as well.  Either way, the current
API handles this fine:  the requests to change will just fail with a convenient error.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

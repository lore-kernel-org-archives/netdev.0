From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bridge: Add 'hairpin' port forwarding mode
Date: Thu, 13 Aug 2009 16:27:16 -0700 (PDT)
Message-ID: <20090813.162716.207478915.davem@davemloft.net>
References: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, ptcongdon@ucdavis.edu,
	evb@yahoogroups.com, bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org, kaber@trash.net,
	arnd@arndb.de, mike.dickson@hp.com, adobriyan@gmail.com,
	bridge@osdl.org
To: anna.fischer@hp.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756451AbZHMX1I@vger.kernel.org>
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Fischer, Anna" <anna.fischer@hp.com>
Date: Thu, 13 Aug 2009 16:55:16 +0000

> This patch adds a 'hairpin' (also called 'reflective relay') mode
> port configuration to the Linux Ethernet bridge kernel module.
> A bridge supporting hairpin forwarding mode can send frames back
> out through the port the frame was received on.
> 
> Hairpin mode is required to support basic VEPA (Virtual
> Ethernet Port Aggregator) capabilities.
> 
> You can find additional information on VEPA here:
> http://tech.groups.yahoo.com/group/evb/
> http://www.ieee802.org/1/files/public/docs2009/new-hudson-vepa_seminar-20090514d.pdf
> http://www.internet2.edu/presentations/jt2009jul/20090719-congdon.pdf
> 
> An additional patch 'bridge-utils: Add 'hairpin' port forwarding mode'
> is provided to allow configuring hairpin mode from userspace tools.
> 
> Signed-off-by: Paul Congdon <paul.congdon@hp.com>
> Signed-off-by: Anna Fischer <anna.fischer@hp.com>

Applied to net-next-2.6

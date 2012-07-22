From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 0/6] tun zerocopy support
Date: Sun, 22 Jul 2012 12:40:20 -0700 (PDT)
Message-ID: <20120722.124020.1299343386554149788.davem@davemloft.net>
References: <cover.1342812067.git.mst@redhat.com>
	<20120720.174902.2055189237500355771.davem@davemloft.net>
	<20120721220534.GA22912@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, Ian.Campbell@citrix.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120721220534.GA22912@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 22 Jul 2012 01:05:34 +0300

> I agree a small win in CPU use is nothing to write home about,
> I don't yet understand why the win is so small - macvtap has zero copy
> supported for a while and it has exactly same issues.
> I hope adding tun zerocopy support upstream will help us
> make progress faster and find the bottleneck, so far not many people use
> macvtap so zero copy mode there didn't make progress.
> 
> I do know why local performance regresses with zero copy enabled:
> instead of plain copy to user we got get user pages and then memcpy.
> We'll need some logic here to detect this and turn off zero copy.
> 
> The core patches will also be helpful for Ian's more ambitious work.
> 
> Overall I think it's a step in the right direction and it's easier to
> work if core parts are upstream, but if you think we need to wait
> until the gains are more significant, I understand that too.

Ok, I've applied this series, let's see what happens.

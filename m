From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 0/6] tun zerocopy support
Date: Fri, 20 Jul 2012 17:49:02 -0700 (PDT)
Message-ID: <20120720.174902.2055189237500355771.davem@davemloft.net>
References: <cover.1342812067.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1342812067.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 20 Jul 2012 22:23:03 +0300

> Same as with macvtap, I get single-percentage wins in CPU utilization
> on guest to external from this patchset, and a performance regression on
> guest to host, so more work is needed until this feature can move out of
> experimental status, but I think it's useful for some people already.
> 
> Pls review and consider for 3.6.

It doesn't improve performance in one case, and hurts performance in
another.

You'll have to give me a more compelling argument than that.  You've
just given me every reason not to include these patches in 3.6

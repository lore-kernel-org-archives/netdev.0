From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan: propagate gso_min_segs
Date: Tue, 22 Mar 2016 19:33:52 -0700
Message-ID: <1458700432.10868.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458696914-16088-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458696914-16088-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-03-23 at 09:35 +0800, Haishuang Yan wrote:
> vlan drivers lack proper propagation of gso_min_segs from lower device.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---

The plan was to get rid of gso_min_segs, as nothing uses it.

Otherwise I would have included this in my recent patches...

For such a rare 'issue' , we believe ndo_features_check() is better,
because it does not slow down the fast path.

Thanks.

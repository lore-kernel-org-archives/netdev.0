From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v1 5/9] forcedeth: implement ndo_get_stats64()
 API
Date: Wed, 9 Nov 2011 23:43:38 +0000
Message-ID: <1320882218.2781.22.camel@bwh-desktop>
References: <cover.1320875577.git.david.decotigny@google.com>
	 <14be343e242ede786e387b1d22f0a9259ec7d862.1320875577.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14be343e242ede786e387b1d22f0a9259ec7d862.1320875577.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-09 at 14:09 -0800, David Decotigny wrote:
> This commit implements the ndo_get_stats64() API for forcedeth. Since
> these stats are being updated from different contexts (process and
> timer), this commit adds protection (locking + atomic variables).
[...]

I don't claim to have reviewed this properly, but it looks reasonable.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

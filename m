From: Rob Landley <rlandley@parallels.com>
Subject: Re: 2.6.38 containers bug: Infinite loop in /proc/sys/net/ipv6/neigh/neigh/neigh...
Date: Wed, 30 Mar 2011 05:45:08 -0500
Message-ID: <4D9309B4.2000501@parallels.com>
References: <4D92E9DC.3070405@parallels.com>	<20110330.020120.02272125.davem@davemloft.net>	<4D9302F3.6080206@parallels.com> <20110330.033529.71582712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	<containers@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<stable@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110330.033529.71582712.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/30/2011 05:35 AM, David Miller wrote:
> From: Rob Landley <rlandley@parallels.com>
> Date: Wed, 30 Mar 2011 05:16:19 -0500
> 
>> Pinging the stable guys to make sure this goes in a dot release.
> 
> Please do not do this.

Too late, but presumably they got your NAK.

> I let fixes soak in Linus's tree for a week or even more before I submit
> them to -stable.

So you think letting it soak in the merge window and the churn of -rc1
(which currently doesn't boot for me due to an ide issue) will provide
more validity than a specific "There was an infinite loop in the
filesystem, there is now no longer an infinite loop in the filesystem,
here's the specific test for it" and visual inspection ofthe patch?

*shrug*  I hear what you say.  It's certainly a point of view.

Rob

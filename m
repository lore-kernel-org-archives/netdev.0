From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] ipv6: log autoconfiguration failures
Date: Thu, 12 Dec 2013 13:24:41 -0500 (EST)
Message-ID: <20131212.132441.1907656115241279246.davem@davemloft.net>
References: <52A99B56.1070503@redhat.com>
	<20131212.122241.2022824170198915190.davem@davemloft.net>
	<52A9F93A.5040104@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvlasenk@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	jpirko@redhat.com
To: vyasevich@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52A9F93A.5040104@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Thu, 12 Dec 2013 12:58:18 -0500

> On 12/12/2013 12:22 PM, David Miller wrote:
>> Give it statistics just like we have for every other kind of similar
>> event.
> 
> The fact that link-local address could not be generated for a specific
> device type does not lend itself well to counting.  There is no way
> from to tell from the counter which device does not support IPv6 autoconfig.

If the statistic is per-device, which I recommended it be implemented as,
you indeed can.

And I do not buy the argument that this is "useless" because the admin
is just going to kill the interface and create a new one.  When you
notice there is a problem, you look at the statistics before doing
that!

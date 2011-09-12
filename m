From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: [PATCH] Check net->nfnl for NULL in ctnetlink_conntrack_event
 to, avoid Oops on container destroy
Date: Mon, 12 Sep 2011 12:42:57 -0600
Message-ID: <4E6E52B1.1070405@canonical.com>
References: <4E6E4961.9070802@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4E6E4961.9070802@canonical.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/12/2011 12:03 PM, Tim Gardner wrote:
> Patrick,
>
> I received this patch from a developer that uses lxc and network name
> spaces. I don't know the locking semantics well enough for CT to judge
> whether this fix is sufficient. Bug info can be found at
> http://bugs.launchpad.net/bugs/843892 . See comment #7 for his analysis.
>
> rtg

Never mind. Looks like Alex already sent this patch on Sept 10 with the 
subject 'Fix repeatable Oops on container destroy with conntrack'.

rtg

-- 
Tim Gardner tim.gardner@canonical.com

From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [BUG] ipv6, rawv6_close(): BUG: unable to handle kernel paging
 request
Date: Mon, 22 Jul 2013 03:00:04 +0530
Message-ID: <51EC52DC.4020304@linux.vnet.ibm.com>
References: <51EC283D.5010208@linux.vnet.ibm.com> <20130721205352.GB15442@order.stressinduktion.org> <51EC4E4B.6040505@linux.vnet.ibm.com> <20130721212713.GA6538@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130721212713.GA6538@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/22/2013 02:57 AM, Hannes Frederic Sowa wrote:
> On Mon, Jul 22, 2013 at 02:40:35AM +0530, Srivatsa S. Bhat wrote:
>> On 07/22/2013 02:23 AM, Hannes Frederic Sowa wrote:
>>> On Sun, Jul 21, 2013 at 11:58:13PM +0530, Srivatsa S. Bhat wrote:
>>>> I'm seeing this on every boot.
>>>>
>>>> Version: Latest mainline (commit ea45ea70b)
>>>
>>> Thanks for the report! Could you try the following patch?
>>>
>>
>> That didn't seem to help :-(
>>
>> Below is the new trace (not much different than the old one).
> 
> Ok, thanks. Do you have CONFIG_IPV6_MROUTE_MULTIPLE_TABLES enabled?
> 

No.

Here are the relevant config options from my .config:

CONFIG_IPV6=m
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET6_XFRM_MODE_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_BEET is not set
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_SIT is not set
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_GRE is not set
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
# CONFIG_IPV6_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IPV6_PIMSM_V2=y
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y


Regards,
Srivatsa S. Bhat

From: Henrik Petander <lpetande@tml.hut.fi>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Fri, 13 Jun 2003 17:27:50 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE9DF66.1090409@tml.hut.fi>
References: <3EE5F85E.9080006@tml.hut.fi>	<20030610.095135.28806569.davem@redhat.com>	<3EE6ECD3.6050103@tml.hut.fi>	<20030611.202003.74721468.davem@redhat.com>	<3EE83D81.5030605@tml.hut.fi> <20030613202652.1d64ed6f.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, lpetande@morphine.tml.hut.fi,
   yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi, jagana@us.ibm.com,
   kumarkr@us.ibm.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <20030613202652.1d64ed6f.nakam@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Masahide NAKAMURA wrote:
> On Thu, 12 Jun 2003 11:44:49 +0300
> Henrik Petander <lpetande@tml.hut.fi> wrote:
>>
>>I don't see a problem in that. It would only result in a short period of 
>>missing mipv6 route optimization information, until MIPv6 daemon 
>>reinserted the mipv6 information. MIPv6 daemon would do this after 
>>getting a notification of the deletion of the old mipv6 related cached 
>>routes. This would relate to zebra in the same way as pmtu discovery.
> 
> 
> When routing information is deleted by zebra, the packets from user
> application will be sent incorrectly until MIPv6 daemon re-inserts
> the special host route.

The packets between Mobile Node and Correspondent Node would be just 
sent through the tunnel via Home Agent. Only parts of the direct traffic 
between MN and HA would be temporarily lost. Since HA is conceptually a 
router, the traffic between MN and HA should be very limited and Mobile 
IP / IPSec signaling would not be affected. This is why IMO the use of 
soft state is acceptable.

> How about making new policy(MIPv6 policy) in the similar way of IPsec?
> MIPv6 and IPsec policy are managed by separated list.

It would be a good solution from our POV, since it should work well with 
IPSec.

Regards,

Henrik

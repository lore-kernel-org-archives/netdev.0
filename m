From: Henrik Petander <lpetande@tml.hut.fi>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Thu, 12 Jun 2003 11:44:49 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE83D81.5030605@tml.hut.fi>
References: <3EE5F85E.9080006@tml.hut.fi>	<20030610.095135.28806569.davem@redhat.com>	<3EE6ECD3.6050103@tml.hut.fi> <20030611.202003.74721468.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, lpetande@morphine.tml.hut.fi,
   yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi, jagana@us.ibm.com,
   kumarkr@us.ibm.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030611.202003.74721468.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Henrik Petander <lpetande@tml.hut.fi>
>    Date: Wed, 11 Jun 2003 11:48:19 +0300
>    
>    Does this make sense to you?
> 
> No it doesn't. When you startup zebra, it may flush the entire
> routing table.


I don't see a problem in that. It would only result in a short period of 
missing mipv6 route optimization information, until MIPv6 daemon 
reinserted the mipv6 information. MIPv6 daemon would do this after 
getting a notification of the deletion of the old mipv6 related cached 
routes. This would relate to zebra in the same way as pmtu discovery.

Regards,

Henrik

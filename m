From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 12:33:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD7832B.3010709@us.ibm.com>
References: <Pine.LNX.4.44.0312102210060.7034-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, "Kevin W. Rudd" <ruddk@us.ibm.com>,
        davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312102210060.7034-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Julian Anastasov wrote:

> 	It can be an option: pmtu_promisc or whatever (default 0).
> We should avoid using TOS as hash key and if the var is 1 we should
> ignore matching the tos keys in ip_rt_frag_needed and ip_rt_redirect.
> By this way, all cache entries between saddr and daddr will be updated, no 
> matter the TOS or even OIF keys. Comments?

This is what I was going to suggest too, but one of the drawbacks
would be needing the user to recompile the distro kernel just
for this..could we keep any fix to this dynamically tunable?

thanks,
Nivedita

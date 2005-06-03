From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 11:59:35 -0700
Message-ID: <42A0A897.5080006@candelatech.com>
References: <468F3FDA28AA87429AD807992E22D07E0450BFE8@orsmsx408>	<42A0A25C.8000503@candelatech.com> <20050603.114950.119242486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, Robert.Olsson@data.slu.se, jdmason@us.ibm.com,
        shemminger@osdl.org, hadi@cyberus.ca, mitch.a.williams@intel.com,
        netdev@oss.sgi.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050603.114950.119242486.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Ben Greear <greearb@candelatech.com>

>>Maybe the poll is disabling the IRQs on the NIC for too long, or something
>>like that?
> 
> 
> In a reply I just sent out to this thread, I postulate that the
> jiffies check is hitting earlier with a lower weight value, a quick
> look at /proc/net/softnet_stat during their testing will confirm or
> deny this theory.

That would basically just decrease the work done in the NAPI poll though,
so I don't see how that could be the problem, since the 'solution' was to
force less work to be done.

> It could also just be a simple bug in the dev->quota accounting
> somewhere.
> 
> Note that, in all of this, I do not have any objections to providing
> a way to configure the dev->weight values.  I will be applying Stephen
> Hemminger's patches.

Good.  The more knobs the merrier, so long as they are at least somewhat
documented and default to good sane values :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS
Date: Sun, 20 Mar 2005 20:10:52 +0100
Message-ID: <423DCABC.3030307@trash.net>
References: <20050314102614.GA9610@gondor.apana.org.au>	 <20050314105313.GA21001@gondor.apana.org.au>	 <20050314111002.GA29156@gondor.apana.org.au>	 <20050315091904.GA6256@gondor.apana.org.au>	 <20050315095837.GA7130@gondor.apana.org.au>	 <20050318090310.GA28443@gondor.apana.org.au>	 <20050318091129.GA28658@gondor.apana.org.au>	 <20050318104013.57d65e99.davem@davemloft.net> <423D9ADA.6050407@trash.net>	 <423DA58D.4050406@protactive.nl> <20050320171707.GE4201@xi.wantstofly.org>	 <423DB7B7.1070604@trash.net> <423DBCCE.8090006@protactive.nl>	 <423DBF6A.1080907@trash.net> <1111344225.1093.68.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ludo Stellingwerff <ludo@protactive.nl>, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1111344225.1093.68.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> BTW, is there any reason the SPD couldnt have been implemented from day
> one using netfilter classification ? Why did we need another speacilized
> classifier? the actions are clearly implementable as targets.

IMO iptables isn't so great that one would actually want to do this.
The entire ruleset needs to be one continous area in memory, so it can
not be changed, only replaced. To make it useable over pfkey would mean
many things that are currently done by iptables in userspace need to be
done in the kernel. There are multiple other reasons, but I don't think
its even worth discussing this. This of course doesn't mean I'm against
reducing the number of different classification engines.

Regards
Patrick

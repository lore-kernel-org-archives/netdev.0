From: jamal <hadi@cyberus.ca>
Subject: Re: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS
Date: 20 Mar 2005 13:43:45 -0500
Message-ID: <1111344225.1093.68.camel@jzny.localdomain>
References: <20050314102614.GA9610@gondor.apana.org.au>
	 <20050314105313.GA21001@gondor.apana.org.au>
	 <20050314111002.GA29156@gondor.apana.org.au>
	 <20050315091904.GA6256@gondor.apana.org.au>
	 <20050315095837.GA7130@gondor.apana.org.au>
	 <20050318090310.GA28443@gondor.apana.org.au>
	 <20050318091129.GA28658@gondor.apana.org.au>
	 <20050318104013.57d65e99.davem@davemloft.net> <423D9ADA.6050407@trash.net>
	 <423DA58D.4050406@protactive.nl> <20050320171707.GE4201@xi.wantstofly.org>
	 <423DB7B7.1070604@trash.net> <423DBCCE.8090006@protactive.nl>
	 <423DBF6A.1080907@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ludo Stellingwerff <ludo@protactive.nl>, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <423DBF6A.1080907@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-03-20 at 13:22, Patrick McHardy wrote:
> Ludo Stellingwerff wrote:
> > I'm hoping that using the fwmark as a selector can provide a workable
> > solution for both mine and Lennert's problem, any many more related
> > situations. Netfilter has a (almost) complete range of selectors.
> > e.g. Lennerts problem could be solved using a combination of the
> > "realm" match of iptables, in combination with a fwmark for SPD matching.
> 
> Routing of local packets is done before the first netfilter hook
> is called, but I forgot about ip_route_me_harder(). So you're right,
> the realm can be translated to nfmark values using iptables.

BTW, is there any reason the SPD couldnt have been implemented from day
one using netfilter classification ? Why did we need another speacilized
classifier? the actions are clearly implementable as targets.

cheers,
jamal

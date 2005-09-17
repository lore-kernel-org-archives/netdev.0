From: jamal <hadi@cyberus.ca>
Subject: Re: Route cache performance
Date: Sat, 17 Sep 2005 11:17:20 -0400
Message-ID: <1126970240.6681.128.camel@localhost.localdomain>
References: <20050825200543.GA6612@yakov.inr.ac.ru>
	 <20050825212211.GA23384@netnation.com>
	 <20050826115520.GA12351@yakov.inr.ac.ru>
	 <17167.29239.469711.847951@robur.slu.se>
	 <20050906235700.GA31820@netnation.com>
	 <17182.64751.340488.996748@robur.slu.se>
	 <20050907162854.GB24735@netnation.com>
	 <20050907195911.GA8382@yakov.inr.ac.ru>
	 <20050913221448.GD15704@netnation.com>
	 <17191.55685.861191.831981@robur.slu.se>
	 <20050917002823.GB19112@netnation.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050917002823.GB19112@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-16-09 at 17:28 -0700, Simon Kirby wrote:

> nf_iterate was near the top even though the firewall was empty, so I
> changed CONFIG_IP_NF_IPTABLES=y to CONFIG_IP_NF_IPTABLES=m (and didn't
> load it).  Throughput went up from 173 Mbps to 232 Mbps...yikes. 
> Conntrack was never compiled.  I'll do some more profiling when I get
> a chance...
> 

If you want some basic stateless firewalling, turn off netfilter and use
tc ingress/egress actions instead. The impact on performance is a lot
more tolerable.

cheers,
jamal

From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 25 Mar 2005 16:44:01 -0500
Message-ID: <1111787040.1092.684.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <423B7BCB.10400@dsl.pipex.com> <1111410890.1092.195.camel@jzny.localdomain>
	 <423F41AD.3010902@dsl.pipex.com>
	 <1111444869.1072.51.camel@jzny.localdomain>
	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>
	 <42408998.5000202@dsl.pipex.com>
	 <1111550254.1089.21.camel@jzny.localdomain>
	 <4241C478.5030309@dsl.pipex.com>
	 <1111607112.1072.48.camel@jzny.localdomain>
	 <4241D764.2030306@dsl.pipex.com>
	 <1111612042.1072.53.camel@jzny.localdomain>
	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>
	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>
	 <1111663947.1037.24.camel@jzny.localdomain>
	 <1111665450.1037.27.camel@jzny.localdomain>
	 <4242DFB5.9040802@dsl.pipex.com>
	 <1111749220.1092.457.camel@jzny.localdomain>
	 <42446DB2.9070809@dsl.pipex.com>
	 <111178
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Remus <rmocius@auste.elnet.lt>,
        netdev <netdev@oss.sgi.com>, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42447BF8.5090806@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 16:00, Patrick McHardy wrote:

> I asked Phil to send a new patch which drops the reference when
> the packet leaves IP. We can't make assumptions about the packets
> fate after that, and the problem with hanging conntrack unload
> really should get fixed once and for all.
> 

Queues which are not getting consumed are always a problem with
skbs.
One of the classical problems i have seen posted is someone
is some person running some IDS or some other thing using 
BPF with more than one socket and having his low mem box being pounded
by some DOS. Soon OOM kicks in and starts randomly killing processes
because skbs are still being refcounted by the user space app that is
now unable to keep up.
i.e it is a generic problem that would happen even with NAPI with lack
of proper feedback. i suppose a contrack reference adds more of a twist
to it ;->

cheers,
jamal

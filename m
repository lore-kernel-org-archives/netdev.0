From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 25 Mar 2005 15:54:16 -0500
Message-ID: <1111784056.1091.666.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
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
	 <1111754346.1092.480.camel@jzny.localdomain>  <42444A14.3090809@trash.net>
	 <1111775660.1092.571.camel@jzny.localdomain
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-W0c9l2vsr4aY6Wo7rZtM"
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Remus <rmocius@auste.elnet.lt>,
        netdev <netdev@oss.sgi.com>, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42447690.1070501@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-W0c9l2vsr4aY6Wo7rZtM
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2005-03-25 at 15:37, Patrick McHardy wrote:

> Yes, that should work.
> 

I think the attached script may help if you call it with something like
1000;
You may need to adapt it slightly so you add the actions with new
filters instead of directly. I would have to do a lot of plumbing from
my scripts to give you one which does just that

cheers,
jamal

--=-W0c9l2vsr4aY6Wo7rZtM
Content-Disposition: inline; filename=add_actions.sh
Content-Type: text/x-sh; name=add_actions.sh; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

#!/bin/sh

tc qdisc del dev eth1 ingress
tc qdisc add dev eth1 ingress

for ((i = 1 ; i <= $1 ; i++))
do
	tc actions add action drop index $i
done

--=-W0c9l2vsr4aY6Wo7rZtM--

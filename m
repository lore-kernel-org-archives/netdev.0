From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 25 Mar 2005 14:22:02 -0500
Message-ID: <1111778521.1092.584.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>
	 <1111410890.1092.195.camel@jzny.localdomain>
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
	 <1
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
In-Reply-To: <1111777717.1090.576.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 14:08, jamal wrote:

> Its narrowed down to be user space problem. Investigating ..

sigh. I just wasted 3 hours on this.

Seems someone (the patch did not come from me) made a change to mirred
code in user space to ensure only a single socket was being used. This
will never work if you have a dump inside a dump. To resolve this in the
patch that i sent to Stephen for mirred had two separate sockets - one
for each dump. I wish i had remembered this a few hours back.

Anyways i will stick with patch i sent Andy.

cheers,
jamal

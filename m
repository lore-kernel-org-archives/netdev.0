From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 23 Mar 2005 19:53:28 -0500
Message-ID: <1111625608.1037.16.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
	 <1110379135.1091.143.camel@jzny.localdomain>
	 <1110416767.1111.76.camel@jzny.localdomain>
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
	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@d
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <4241F7F0.2010403@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Never mind, I have reproduced this as well. It doesnt happen in all
targets it seems - just some. 

I will look at the netfilter code later and try and figure to unbreak
this. I think i will have to find a big bat and flog some of the
netfilter people responsible for breaking this ABI. 

cheers,
jamal

On Wed, 2005-03-23 at 18:12, Andy Furniss wrote:
> Andy Furniss wrote:
> > jamal wrote:
> > 
> >> On Wed, 2005-03-23 at 15:53, Andy Furniss wrote:
> >>
> >>
> >>> but I can now follow the action ipt MARK line with an action mirred ..
> >>>
> >>> and I just get the MARK error
> >>>
> >>> tablename: mangle hook: NF_IP_PRE_ROUTING
> >>>         target: MARK set 0x1  index 0
> >>> RTNETLINK answers: Invalid argument
> >>> We have an error talking to the kernel
> >>>
> >>>
> >>
> >>
> >> Ok, this is my worry - that it works when everything is compiled in
> >> but not when as modules.
> >> So when you rebuild compile everything in.
> > 
> > 
> > Compiled everything in but it still doesn't work.
> > 
> > Andy.
> 
> Noticed I get this in logs
> 
> Mar 23 23:11:18 amd kernel: MARK: targinfosize 8 != 4
> 
> Andy.
> 
> 
> 
> 

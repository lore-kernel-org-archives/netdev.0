From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Thu, 24 Mar 2005 15:41:41 +0000
Message-ID: <4242DFB5.9040802@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <00c301c524b4$938cd240$6e69690a@RIMAS>	 <1110379135.1091.143.camel@jzny.localdomain>	 <1110416767.1111.76.camel@jzny.localdomain>	 <025501c52552$2dbf87c0$6e69690a@RIMAS>	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com>	 <1111444869.1072.51.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>	 <42408998.5000202@dsl.pipex.com>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com>	 <1111607112.1072.48.camel@jzny.localdomain>	 <4241D764.2030306@dsl.pipex.com>	 <1111612042.1072.53.camel@jzny.localdomain>	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>	 <1111625608.1037.16.camel@jzny.localdomain>  <424212F7.10106@dsl.pipex.com>	 <1111663947.
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111665450.1037.27.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2005-03-24 at 06:32, jamal wrote:
> 
> 
>>Need caffeine, I think i will find some workaround - I should probably
>>put it in user space.
>>
> 
> 
> Ok, try attached patch on tc - seems to work for me

Yes - it works fine now - thanks.

I can still get

tc -s filter ls dev eth0 parent ffff:

to not exit till <ctrl><c> (ps shows it aswell) - I tested from clean 
boot without X/KDE etc. It only happens with action mirred egress redirect.

action ipt or action ok don't cause it.

Andy.

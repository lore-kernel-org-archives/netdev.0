From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Wed, 23 Mar 2005 20:53:56 +0000
Message-ID: <4241D764.2030306@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>	 <1107174142.8021.121.camel@jzny.localdomain>	 <00c301c524b4$938cd240$6e69690a@RIMAS>	 <1110379135.1091.143.camel@jzny.localdomain>	 <1110416767.1111.76.camel@jzny.localdomain>	 <025501c52552$2dbf87c0$6e69690a@RIMAS>	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com>	 <1111444869.1072.51.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>	 <42408998.5000202@dsl.pipex.com>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com> <1111607112.1072.48.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111607112.1072.48.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> 
> Ok, try the module thing; actually try to modprobe mark target first and
> see if that works as well.

Looks like they load OK - anyway I rebooted and modprobed ipt and 
ipt_MARK before test and it still fails - will do new kernel a bit later.

> 
> 
>>I get exactly the same error if I also add action mirred egress redirect 
>>dev lo - before I would get different.
>>
> 
> 
> Didnt follow - still related to ipt?

When action ipt MARK failed in previous tests and was followed by an 
action mirred ...

I would get an error like
...
bad action type mirred
...

but I can now follow the action ipt MARK line with an action mirred ..

and I just get the MARK error

tablename: mangle hook: NF_IP_PRE_ROUTING
         target: MARK set 0x1  index 0
RTNETLINK answers: Invalid argument
We have an error talking to the kernel



Andy.

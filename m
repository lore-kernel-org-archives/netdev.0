From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Fri, 25 Mar 2005 21:18:36 +0000
Message-ID: <4244802C.7020202@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com>	 <1111444869.1072.51.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>	 <42408998.5000202@dsl.pipex.com>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com>	 <1111607112.1072.48.camel@jzny.localdomain>	 <4241D764.2030306@dsl.pipex.com>	 <1111612042.1072.53.camel@jzny.localdomain>	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>	 <1111663947.1037.24.camel@jzny.localdomain>	 <1111665450.1037.27.camel@jzny.localdomain>	 <4242DFB5.9040802@dsl.pipex.com>	 <1111749220.1092.457.camel@jzny.localdomain>	 <42446DB2.9070
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev <netdev@oss.sgi.com>,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111781443.1092.631.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> 
> Things will work once the  "action track" is in place; i.e you would
> then say:
> "match xxx .. \
>  action track \
>  action connmark"

OK I would need that to recreate what I do now with IMQ hooked after 
deNAT so I can see local addresses and use connbytes in prerouting 
mangle (though that's on my 2.4 I can't get connbytes to work with 
latest netfilter yet anyway)

> 
> If i was to prioritize my time for new actions - how important is this?

Things are OK for me with IMQ - low bandwidth and not many filters seem 
fine. At high bandwidth/lots of filters it seems problematic - but then 
most people can use dummy now :-)

I'll have to re-run a test I did recently which was lots of tc filter 
matches at 8000pps - on egress IMQ was almost as good as directly on 
eth0. On ingress it was more than 10X worse.

> I also wish someone else would start writting some of these actions ;->
> Wanna right the tracking one? I could help - wink.

LOL - you'd probably end up writing it all anyway.

I really should try and get into coding more though, apart from a few 
small hacks I have had no practice with C/kernel stuff.

Andy.

From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: IMQ again WAS(Re: iptables breakage WAS(Re: dummy as IMQ	replacement
Date: Sun, 27 Mar 2005 20:35:21 +0100
Message-ID: <42470AF9.8050402@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com>	 <1111444869.1072.51.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>	 <42408998.5000202@dsl.pipex.com>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com>	 <1111607112.1072.48.camel@jzny.localdomain>	 <4241D764.2030306@dsl.pipex.com>	 <1111612042.1072.53.camel@jzny.localdomain>	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>	 <1111663947.1037.24.camel@jzny.localdomain>	 <1111665450.1037.27.camel@jzny.localdomain>	 <4242DFB5.9040802@dsl.pipex.com>	 <1111749220.1092.457.camel@jzny.localdomain>	 <42446DB2.9070809@dsl.pipex.com>	 <1111781443.1092.631.camel@jzny.localdomain>	 <4244802C.
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev <netdev@oss.sgi.com>,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111788760.1090.712.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>>I'll have to re-run a test I did recently which was lots of tc filter 
>>matches at 8000pps - on egress IMQ was almost as good as directly on 
>>eth0. On ingress it was more than 10X worse.
>>
> How many filters? I wont suspect any difference between ingress 
> and egress.

You are right - the test was to blame.

I was using my old PC as sender, it's frozen in time at 2.4.20 which for 
some reason has a txqueuelen on eth0 of 0. It doesn't show using netperf 
when just testing LAN speed - but makes alot of difference for the test 
I did - ifconfig eth0 txqueuelen 1000 fixed it.

Andy.

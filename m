From: Patrick McHardy <kaber@trash.net>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Wed, 23 Mar 2005 02:31:58 +0100
Message-ID: <4240C70E.8060503@trash.net>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>	 <1107174142.8021.121.camel@jzny.localdomain>	 <00c301c524b4$938cd240$6e69690a@RIMAS>	 <1110379135.1091.143.camel@jzny.localdomain>	 <1110416767.1111.76.camel@jzny.localdomain>	 <025501c52552$2dbf87c0$6e69690a@RIMAS>	 <1110453757.1108.87.camel@jzny.localdomain>  <423B7BCB.10400@dsl.pipex.com> <1111410890.1092.195.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Remus <rmocius@auste.elnet.lt>,
        netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>,
        Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
To: hadi@cyberus.ca
In-Reply-To: <1111410890.1092.195.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> As i was suspecting this is related to iptables breaking backwards
> compatibility. Starting with 1.3.0 the target structure changed ;->
> (right at the top is a new field called version)
> I suspect the iptables folks maybe unaware that there are other users of
> iptables and assume that anyone needing to use new iptables will
> recompile everything from scratch. BAD! BAD!
> I am ccing the necessary evil doers (Harald and Patrick - at least they
> would know who the real evildoer is). 

We'll try to keep this in mind in the future. We could move
the version field to the end, but I guess its already too
late. What do you think?

Regards
Patrick

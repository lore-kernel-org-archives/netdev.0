From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 10 Mar 2005 06:22:38 -0500
Message-ID: <1110453757.1108.87.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
	 <1110379135.1091.143.camel@jzny.localdomain>
	 <1110416767.1111.76.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: Remus <rmocius@auste.elnet.lt>
In-Reply-To: <025501c52552$2dbf87c0$6e69690a@RIMAS>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Remus,
I could not reproduce this one - it is also a bit odd for calloc to
fail. I dont have iptables 1.3.1 but i will get and retry.
Does this happen all the time?

cheers,
jamal

On Thu, 2005-03-10 at 04:18, Remus wrote:
> Hi Jamal,
> 
> Thanks for the patch.
> That error is gone but I got a new error:
> 
> ifconfig dummy0 up
> tc qdisc add dev eth2 ingress
> tc filter add dev eth2 parent ffff: protocol ip prio 10 u32 match u32 0 0 
> flowid 1:1 action ipt -j MARK --set-mark 1 action mirred egress redirect dev 
> dummy0
> iptables: calloc failed: Cannot allocate memory
> 
> I use 2.6.11.2 kernel patched with your dummy patch, iptables 1.3.1 and the 
> latest iproute2 patched with the pacth you sent yesterday.
> 
> 
> Regards
> 
> Remus
> 
> 
> ----- Original Message ----- 
> From: "Jamal Hadi Salim" <hadi@znyx.com>
> To: "Remus" <rmocius@auste.elnet.lt>
> Cc: <netdev@oss.sgi.com>; "Nguyen Dinh Nam" <nguyendinhnam@gmail.com>; 
> "Andre Tomt" <andre@tomt.net>; <syrius.ml@no-log.org>; "Andy Furniss" 
> <andy.furniss@dsl.pipex.com>; "Damion de Soto" <damion@snapgear.com>
> Sent: Thursday, March 10, 2005 1:06 AM
> Subject: Re: dummy as IMQ replacement
> 
> 
> > Hi Remus,
> >
> > Please try this patch on top of latest iproute2. Credit to Patrick for
> > spoting it. I dont know when or who made this change - in any case it
> > doesnt matter if it works for you.
> >
> > cheers,
> >
> > On Wed, 2005-03-09 at 09:38, jamal wrote:
> >
> >> I have to go to work - so wont have time to look at this for sometime.
> >> Maybe some of the netfilter folks like Patrick can solve it for you
> >> before i get back.
> >>
> >> cheers,
> >> jamal
> >>
> > 
> 
> 
> 
> 

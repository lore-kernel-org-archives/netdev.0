From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 09 Mar 2005 09:38:56 -0500
Message-ID: <1110379135.1091.143.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: Remus <rmocius@auste.elnet.lt>
In-Reply-To: <00c301c524b4$938cd240$6e69690a@RIMAS>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-09 at 09:30, Remus wrote:
> Hi Jamal,
> 
> 
> I have problem with iproute2:
> 1) if I use current iproute2 I get this error when I run this command:
> tc filter add dev eth2 parent ffff: protocol ip prio 10 u32 match u32 0 0 
> flowid 1:1 action ipt -j MARK --set-mark 1 action mirred egress redirect dev 
> dummy0
> /usr/local/lib/iptables/libipt_mark.so: undefined symbol: register_match
>  failed to find target MARK
> 

That should work. Dont bother with iproute2-2.6.9-jamal.
What version of iptables are you using? Unfortunately i have to keep
track of changes happening in iptables as well and they keep changing
the interface from under me. Try to use the same iptables version as the
one whose headers are found in the iproute2 version you are using.

I have to go to work - so wont have time to look at this for sometime.
Maybe some of the netfilter folks like Patrick can solve it for you
before i get back.

cheers,
jamal

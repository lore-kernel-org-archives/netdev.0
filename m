From: "Remus" <rmocius@auste.elnet.lt>
Subject: Re: dummy as IMQ replacement
Date: Wed, 9 Mar 2005 14:30:42 -0000
Message-ID: <00c301c524b4$938cd240$6e69690a@RIMAS>
References: <1107123123.8021.80.camel@jzny.localdomain> <0fcf01c5077f$579e4b80$6e69690a@RIMAS> <1107174142.8021.121.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, "Nguyen Dinh Nam" <nguyendinhnam@gmail.com>,
        "Andre Tomt" <andre@tomt.net>, <syrius.ml@no-log.org>,
        "Andy Furniss" <andy.furniss@dsl.pipex.com>,
        "Damion de Soto" <damion@snapgear.com>
To: <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,


I have problem with iproute2:
1) if I use current iproute2 I get this error when I run this command:
tc filter add dev eth2 parent ffff: protocol ip prio 10 u32 match u32 0 0 
flowid 1:1 action ipt -j MARK --set-mark 1 action mirred egress redirect dev 
dummy0
/usr/local/lib/iptables/libipt_mark.so: undefined symbol: register_match
 failed to find target MARK

bad action parsing
parse_action: bad value (11:ipt)!
Illegal "action"


2) if I use iproute2-2.6.9-jamal  I get this error:
 tc filter add dev eth2 parent ffff: protocol ip prio 10 u32 match u32 0 0 
flowid 1:1 action ipt -j MARK --set-mark 1 action mirred egress redirect dev 
dummy0
bad action type ipt
Usage: ... gact <ACTION> [RAND] [INDEX]
Where: ACTION := reclassify | drop | continue | pass RAND := random 
<RANDTYPE> <ACTION> <VAL>RANDTYPE := netrand | determVAL : = value not 
exceeding 10000INDEX := index value used
bad action parsing
parse_action: bad value (11:ipt)!
Illegal "action"

Any ideas?

May I use some iptables command to forward all incomming traffic to dummy?

Regards


Remus

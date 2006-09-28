From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Thu, 28 Sep 2006 15:50:52 -0700
Message-ID: <20060928155052.63ed5ce8@freekitty>
References: <20060919.000800.127570535.yoshfuji@linux-ipv6.org>
	<20060927.224444.109879330.davem@davemloft.net>
	<20060928083645.786b1ab1@freekitty>
	<20060928.143304.83622307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14056 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161359AbWI1WvL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 18:51:11 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060928.143304.83622307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006 14:33:04 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Thu, 28 Sep 2006 08:36:45 -0700
>=20
> > Please figure out how to keep rtnetlink.h useful from user space.
> > I tried putting the current sanitized version of rtnetlink.h into
> > iproute2 and the build fails.=20
>=20
> Please give the error so I have a chance of fixing this.

If I put 2.6.19 headers in:


In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
/usr/include/linux/if.h:117: error: redefinition of =E2=80=98struct ifm=
ap=E2=80=99
/usr/include/linux/if.h:153: error: redefinition of =E2=80=98struct ifr=
eq=E2=80=99
/usr/include/linux/if.h:203: error: redefinition of =E2=80=98struct ifc=
onf=E2=80=99
ll_map.c: In function =E2=80=98ll_remember_index=E2=80=99:
ll_map.c:45: error: =E2=80=98IFLA_MAX=E2=80=99 undeclared (first use in=
 this function)
ll_map.c:45: error: (Each undeclared identifier is reported only once
ll_map.c:45: error: for each function it appears in.)
ll_map.c:55: warning: implicit declaration of function =E2=80=98IFLA_RT=
A=E2=80=99
ll_map.c:55: warning: implicit declaration of function =E2=80=98IFLA_PA=
YLOAD=E2=80=99
ll_map.c:55: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=80=
=99 makes pointer from integer without a cast
ll_map.c:56: error: =E2=80=98IFLA_IFNAME=E2=80=99 undeclared (first use=
 in this function)
ll_map.c:76: error: =E2=80=98IFLA_ADDRESS=E2=80=99 undeclared (first us=
e in this function)
ll_map.c:45: warning: unused variable =E2=80=98tb=E2=80=99
make[1]: *** [ll_map.o] Error 1
utils.c: In function =E2=80=98inet_addr_match=E2=80=99:
utils.c:333: warning: initialization discards qualifiers from pointer t=
arget type
utils.c:334: warning: initialization discards qualifiers from pointer t=
arget type
make[1]: Target `all' not remade because of errors.
ipaddress.c: In function =E2=80=98print_linkinfo=E2=80=99:
ipaddress.c:135: error: =E2=80=98IFLA_MAX=E2=80=99 undeclared (first us=
e in this function)
ipaddress.c:135: error: (Each undeclared identifier is reported only on=
ce
ipaddress.c:135: error: for each function it appears in.)
ipaddress.c:151: warning: implicit declaration of function =E2=80=98IFL=
A_RTA=E2=80=99
ipaddress.c:151: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=
=80=99 makes pointer from integer without a cast
ipaddress.c:152: error: =E2=80=98IFLA_IFNAME=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:167: error: =E2=80=98IFLA_LINK=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:182: error: =E2=80=98IFLA_MTU=E2=80=99 undeclared (first us=
e in this function)
ipaddress.c:184: error: =E2=80=98IFLA_QDISC=E2=80=99 undeclared (first =
use in this function)
ipaddress.c:200: error: =E2=80=98IFLA_ADDRESS=E2=80=99 undeclared (firs=
t use in this function)
ipaddress.c:206: error: =E2=80=98IFLA_BROADCAST=E2=80=99 undeclared (fi=
rst use in this function)
ipaddress.c:217: error: =E2=80=98IFLA_STATS=E2=80=99 undeclared (first =
use in this function)
ipaddress.c:218: error: storage size of =E2=80=98slocal=E2=80=99 isn=E2=
=80=99t known
ipaddress.c:226: error: dereferencing pointer to incomplete type
ipaddress.c:228: error: dereferencing pointer to incomplete type
ipaddress.c:228: error: dereferencing pointer to incomplete type
ipaddress.c:228: error: dereferencing pointer to incomplete type
ipaddress.c:229: error: dereferencing pointer to incomplete type
ipaddress.c:229: error: dereferencing pointer to incomplete type
ipaddress.c:230: error: dereferencing pointer to incomplete type
ipaddress.c:232: error: dereferencing pointer to incomplete type
ipaddress.c:233: error: dereferencing pointer to incomplete type
ipaddress.c:238: error: dereferencing pointer to incomplete type
ipaddress.c:239: error: dereferencing pointer to incomplete type
ipaddress.c:240: error: dereferencing pointer to incomplete type
ipaddress.c:241: error: dereferencing pointer to incomplete type
ipaddress.c:242: error: dereferencing pointer to incomplete type
ipaddress.c:247: error: dereferencing pointer to incomplete type
ipaddress.c:249: error: dereferencing pointer to incomplete type
ipaddress.c:249: error: dereferencing pointer to incomplete type
ipaddress.c:249: error: dereferencing pointer to incomplete type
ipaddress.c:250: error: dereferencing pointer to incomplete type
ipaddress.c:250: error: dereferencing pointer to incomplete type
ipaddress.c:250: error: dereferencing pointer to incomplete type
ipaddress.c:251: error: dereferencing pointer to incomplete type
ipaddress.c:252: error: dereferencing pointer to incomplete type
ipaddress.c:257: error: dereferencing pointer to incomplete type
ipaddress.c:258: error: dereferencing pointer to incomplete type
ipaddress.c:259: error: dereferencing pointer to incomplete type
ipaddress.c:260: error: dereferencing pointer to incomplete type
ipaddress.c:218: warning: unused variable =E2=80=98slocal=E2=80=99
ipaddress.c:135: warning: unused variable =E2=80=98tb=E2=80=99
ipaddress.c: In function =E2=80=98print_addrinfo=E2=80=99:
ipaddress.c:285: error: =E2=80=98IFA_MAX=E2=80=99 undeclared (first use=
 in this function)
ipaddress.c:291: error: dereferencing pointer to incomplete type
ipaddress.c:300: warning: implicit declaration of function =E2=80=98IFA=
_RTA=E2=80=99
ipaddress.c:300: error: dereferencing pointer to incomplete type
ipaddress.c:300: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=
=80=99 makes pointer from integer without a cast
ipaddress.c:302: error: =E2=80=98IFA_LOCAL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:303: error: =E2=80=98IFA_ADDRESS=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:307: error: dereferencing pointer to incomplete type
ipaddress.c:309: error: dereferencing pointer to incomplete type
ipaddress.c:311: error: dereferencing pointer to incomplete type
ipaddress.c:316: error: =E2=80=98IFA_LABEL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:319: error: dereferencing pointer to incomplete type
ipaddress.c:327: error: dereferencing pointer to incomplete type
ipaddress.c:334: error: dereferencing pointer to incomplete type
ipaddress.c:358: error: dereferencing pointer to incomplete type
ipaddress.c:358: error: dereferencing pointer to incomplete type
ipaddress.c:359: error: dereferencing pointer to incomplete type
ipaddress.c:361: error: dereferencing pointer to incomplete type
ipaddress.c:363: error: dereferencing pointer to incomplete type
ipaddress.c:365: error: dereferencing pointer to incomplete type
ipaddress.c:368: error: dereferencing pointer to incomplete type
ipaddress.c:371: error: dereferencing pointer to incomplete type
ipaddress.c:378: error: dereferencing pointer to incomplete type
ipaddress.c:381: error: dereferencing pointer to incomplete type
ipaddress.c:385: error: dereferencing pointer to incomplete type
ipaddress.c:389: error: =E2=80=98IFA_BROADCAST=E2=80=99 undeclared (fir=
st use in this function)
ipaddress.c:391: error: dereferencing pointer to incomplete type
ipaddress.c:396: error: =E2=80=98IFA_ANYCAST=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:398: error: dereferencing pointer to incomplete type
ipaddress.c:403: error: dereferencing pointer to incomplete type
ipaddress.c:404: error: dereferencing pointer to incomplete type
ipaddress.c:404: error: =E2=80=98IFA_F_SECONDARY=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:405: error: dereferencing pointer to incomplete type
ipaddress.c:408: error: dereferencing pointer to incomplete type
ipaddress.c:408: error: =E2=80=98IFA_F_TENTATIVE=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:409: error: dereferencing pointer to incomplete type
ipaddress.c:412: error: dereferencing pointer to incomplete type
ipaddress.c:412: error: =E2=80=98IFA_F_DEPRECATED=E2=80=99 undeclared (=
first use in this function)
ipaddress.c:413: error: dereferencing pointer to incomplete type
ipaddress.c:416: error: dereferencing pointer to incomplete type
ipaddress.c:416: error: =E2=80=98IFA_F_PERMANENT=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:419: error: dereferencing pointer to incomplete type
ipaddress.c:420: error: dereferencing pointer to incomplete type
ipaddress.c:421: error: dereferencing pointer to incomplete type
ipaddress.c:424: error: =E2=80=98IFA_CACHEINFO=E2=80=99 undeclared (fir=
st use in this function)
ipaddress.c:428: error: dereferencing pointer to incomplete type
ipaddress.c:431: error: dereferencing pointer to incomplete type
ipaddress.c:432: error: dereferencing pointer to incomplete type
ipaddress.c:435: error: dereferencing pointer to incomplete type
ipaddress.c:285: warning: unused variable =E2=80=98rta_tb=E2=80=99
ipaddress.c: In function =E2=80=98print_selected_addrinfo=E2=80=99:
ipaddress.c:462: error: dereferencing pointer to incomplete type
ipaddress.c:463: error: dereferencing pointer to incomplete type
ipaddress.c: In function =E2=80=98ipaddr_list_or_flush=E2=80=99:
ipaddress.c:538: error: =E2=80=98IFA_F_PERMANENT=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:544: error: =E2=80=98IFA_F_SECONDARY=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:550: error: =E2=80=98IFA_F_TENTATIVE=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:553: error: =E2=80=98IFA_F_DEPRECATED=E2=80=99 undeclared (=
first use in this function)
ipaddress.c:655: error: dereferencing pointer to incomplete type
ipaddress.c:656: error: dereferencing pointer to incomplete type
ipaddress.c:658: error: dereferencing pointer to incomplete type
ipaddress.c:660: error: dereferencing pointer to incomplete type
ipaddress.c:663: error: =E2=80=98IFA_MAX=E2=80=99 undeclared (first use=
 in this function)
ipaddress.c:664: warning: implicit declaration of function =E2=80=98IFA=
_PAYLOAD=E2=80=99
ipaddress.c:664: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=
=80=99 makes pointer from integer without a cast
ipaddress.c:665: error: =E2=80=98IFA_LOCAL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:666: error: =E2=80=98IFA_ADDRESS=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:671: error: dereferencing pointer to incomplete type
ipaddress.c:679: error: =E2=80=98IFA_LABEL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:682: error: dereferencing pointer to incomplete type
ipaddress.c:663: warning: unused variable =E2=80=98tb=E2=80=99
ipaddress.c: In function =E2=80=98ipaddr_modify=E2=80=99:
ipaddress.c:738: error: field =E2=80=98ifa=E2=80=99 has incomplete type
ipaddress.c:754: error: invalid application of =E2=80=98sizeof=E2=80=99=
 to incomplete type =E2=80=98struct ifaddrmsg=E2=80=99=20
ipaddress.c:770: error: =E2=80=98IFA_ADDRESS=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:786: error: =E2=80=98IFA_BROADCAST=E2=80=99 undeclared (fir=
st use in this function)
ipaddress.c:797: error: =E2=80=98IFA_ANYCAST=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:812: error: =E2=80=98IFA_LABEL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:825: error: =E2=80=98IFA_LOCAL=E2=80=99 undeclared (first u=
se in this function)
make[1]: *** [ipaddress.o] Error 1
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from ipneigh.c:30:
/usr/include/linux/if.h:117: error: redefinition of =E2=80=98struct ifm=
ap=E2=80=99
/usr/include/linux/if.h:153: error: redefinition of =E2=80=98struct ifr=
eq=E2=80=99
/usr/include/linux/if.h:203: error: redefinition of =E2=80=98struct ifc=
onf=E2=80=99
ipneigh.c: In function =E2=80=98nud_state_a2n=E2=80=99:
ipneigh.c:63: error: =E2=80=98NUD_PERMANENT=E2=80=99 undeclared (first =
use in this function)
ipneigh.c:63: error: (Each undeclared identifier is reported only once
ipneigh.c:63: error: for each function it appears in.)
ipneigh.c:65: error: =E2=80=98NUD_REACHABLE=E2=80=99 undeclared (first =
use in this function)
ipneigh.c:67: error: =E2=80=98NUD_NOARP=E2=80=99 undeclared (first use =
in this function)
ipneigh.c:69: error: =E2=80=98NUD_NONE=E2=80=99 undeclared (first use i=
n this function)
ipneigh.c:71: error: =E2=80=98NUD_STALE=E2=80=99 undeclared (first use =
in this function)
ipneigh.c:73: error: =E2=80=98NUD_INCOMPLETE=E2=80=99 undeclared (first=
 use in this function)
ipneigh.c:75: error: =E2=80=98NUD_DELAY=E2=80=99 undeclared (first use =
in this function)
ipneigh.c:77: error: =E2=80=98NUD_PROBE=E2=80=99 undeclared (first use =
in this function)
ipneigh.c:79: error: =E2=80=98NUD_FAILED=E2=80=99 undeclared (first use=
 in this function)
ipneigh.c: In function =E2=80=98ipneigh_modify=E2=80=99:
ipneigh.c:104: error: field =E2=80=98ndm=E2=80=99 has incomplete type
ipneigh.c:115: error: invalid application of =E2=80=98sizeof=E2=80=99 t=
o incomplete type =E2=80=98struct ndmsg=E2=80=99=20
ipneigh.c:119: error: =E2=80=98NUD_PERMANENT=E2=80=99 undeclared (first=
 use in this function)
ipneigh.c:142: error: =E2=80=98NTF_PROXY=E2=80=99 undeclared (first use=
 in this function)
ipneigh.c:165: error: =E2=80=98NDA_DST=E2=80=99 undeclared (first use i=
n this function)
ipneigh.c:172: error: =E2=80=98NDA_LLADDR=E2=80=99 undeclared (first us=
e in this function)
ipneigh.c: In function =E2=80=98print_neigh=E2=80=99:
ipneigh.c:194: error: =E2=80=98NDA_MAX=E2=80=99 undeclared (first use i=
n this function)
ipneigh.c:203: error: dereferencing pointer to incomplete type
ipneigh.c:212: error: dereferencing pointer to incomplete type
ipneigh.c:214: error: dereferencing pointer to incomplete type
ipneigh.c:216: error: dereferencing pointer to incomplete type
ipneigh.c:217: error: dereferencing pointer to incomplete type
ipneigh.c:218: error: dereferencing pointer to incomplete type
ipneigh.c:221: warning: implicit declaration of function =E2=80=98NDA_R=
TA=E2=80=99
ipneigh.c:221: error: dereferencing pointer to incomplete type
ipneigh.c:221: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=80=
=99 makes pointer from integer without a cast
ipneigh.c:223: error: =E2=80=98NDA_DST=E2=80=99 undeclared (first use i=
n this function)
ipneigh.c:227: error: dereferencing pointer to incomplete type
ipneigh.c:233: error: =E2=80=98NDA_CACHEINFO=E2=80=99 undeclared (first=
 use in this function)
ipneigh.c:235: error: dereferencing pointer to incomplete type
ipneigh.c:258: error: dereferencing pointer to incomplete type
ipneigh.c:263: error: dereferencing pointer to incomplete type
ipneigh.c:264: error: dereferencing pointer to incomplete type
ipneigh.c:265: error: =E2=80=98NDA_LLADDR=E2=80=99 undeclared (first us=
e in this function)
ipneigh.c:269: error: dereferencing pointer to incomplete type
ipneigh.c:272: error: dereferencing pointer to incomplete type
ipneigh.c:272: error: =E2=80=98NTF_ROUTER=E2=80=99 undeclared (first us=
e in this function)
ipneigh.c:280: error: dereferencing pointer to incomplete type
ipneigh.c:281: error: dereferencing pointer to incomplete type
ipneigh.c:282: error: dereferencing pointer to incomplete type
ipneigh.c:283: error: dereferencing pointer to incomplete type
ipneigh.c:283: error: dereferencing pointer to incomplete type
ipneigh.c:293: error: dereferencing pointer to incomplete type
ipneigh.c:294: error: dereferencing pointer to incomplete type
ipneigh.c:299: error: =E2=80=98NUD_INCOMPLETE=E2=80=99 undeclared (firs=
t use in this function)
ipneigh.c:300: error: =E2=80=98NUD_REACHABLE=E2=80=99 undeclared (first=
 use in this function)
ipneigh.c:301: error: =E2=80=98NUD_STALE=E2=80=99 undeclared (first use=
 in this function)
ipneigh.c:302: error: =E2=80=98NUD_DELAY=E2=80=99 undeclared (first use=
 in this function)
ipneigh.c:303: error: =E2=80=98NUD_PROBE=E2=80=99 undeclared (first use=
 in this function)
ipneigh.c:304: error: =E2=80=98NUD_FAILED=E2=80=99 undeclared (first us=
e in this function)
ipneigh.c:305: error: =E2=80=98NUD_NOARP=E2=80=99 undeclared (first use=
 in this function)
ipneigh.c:306: error: =E2=80=98NUD_PERMANENT=E2=80=99 undeclared (first=
 use in this function)
ipneigh.c:194: warning: unused variable =E2=80=98tb=E2=80=99
ipneigh.c: In function =E2=80=98do_show_or_flush=E2=80=99:
ipneigh.c:336: error: =E2=80=98NUD_PERMANENT=E2=80=99 undeclared (first=
 use in this function)
ipneigh.c:336: error: =E2=80=98NUD_NOARP=E2=80=99 undeclared (first use=
 in this function)
ipneigh.c:394: error: =E2=80=98NUD_FAILED=E2=80=99 undeclared (first us=
e in this function)
make[1]: *** [ipneigh.o] Error 1
ipntable.c: In function =E2=80=98ipntable_modify=E2=80=99:
ipntable.c:67: error: field =E2=80=98ndtm=E2=80=99 has incomplete type
ipntable.c:79: error: invalid application of =E2=80=98sizeof=E2=80=99 t=
o incomplete type =E2=80=98struct ndtmsg=E2=80=99=20
ipntable.c:89: error: =E2=80=98NDTA_PARMS=E2=80=99 undeclared (first us=
e in this function)
ipntable.c:89: error: (Each undeclared identifier is reported only once
ipntable.c:89: error: for each function it appears in.)
ipntable.c:102: error: =E2=80=98NDTA_NAME=E2=80=99 undeclared (first us=
e in this function)
ipntable.c:112: error: =E2=80=98NDTA_THRESH1=E2=80=99 undeclared (first=
 use in this function)
ipntable.c:122: error: =E2=80=98NDTA_THRESH2=E2=80=99 undeclared (first=
 use in this function)
ipntable.c:132: error: =E2=80=98NDTA_THRESH3=E2=80=99 undeclared (first=
 use in this function)
ipntable.c:142: error: =E2=80=98NDTA_GC_INTERVAL=E2=80=99 undeclared (f=
irst use in this function)
ipntable.c:155: error: =E2=80=98NDTPA_IFINDEX=E2=80=99 undeclared (firs=
t use in this function)
ipntable.c:165: error: =E2=80=98NDTPA_BASE_REACHABLE_TIME=E2=80=99 unde=
clared (first use in this function)
ipntable.c:177: error: =E2=80=98NDTPA_RETRANS_TIME=E2=80=99 undeclared =
(first use in this function)
ipntable.c:189: error: =E2=80=98NDTPA_GC_STALETIME=E2=80=99 undeclared =
(first use in this function)
ipntable.c:201: error: =E2=80=98NDTPA_DELAY_PROBE_TIME=E2=80=99 undecla=
red (first use in this function)
ipntable.c:215: error: =E2=80=98NDTPA_QUEUE_LEN=E2=80=99 undeclared (fi=
rst use in this function)
ipntable.c:226: error: =E2=80=98NDTPA_APP_PROBES=E2=80=99 undeclared (f=
irst use in this function)
ipntable.c:237: error: =E2=80=98NDTPA_UCAST_PROBES=E2=80=99 undeclared =
(first use in this function)
ipntable.c:248: error: =E2=80=98NDTPA_MCAST_PROBES=E2=80=99 undeclared =
(first use in this function)
ipntable.c:259: error: =E2=80=98NDTPA_ANYCAST_DELAY=E2=80=99 undeclared=
 (first use in this function)
ipntable.c:271: error: =E2=80=98NDTPA_PROXY_DELAY=E2=80=99 undeclared (=
first use in this function)
ipntable.c:283: error: =E2=80=98NDTPA_PROXY_QLEN=E2=80=99 undeclared (f=
irst use in this function)
ipntable.c:294: error: =E2=80=98NDTPA_LOCKTIME=E2=80=99 undeclared (fir=
st use in this function)
ipntable.c: In function =E2=80=98print_ntable=E2=80=99:
ipntable.c:357: error: =E2=80=98NDTA_MAX=E2=80=99 undeclared (first use=
 in this function)
ipntable.c:358: error: =E2=80=98NDTPA_MAX=E2=80=99 undeclared (first us=
e in this function)
ipntable.c:366: error: dereferencing pointer to incomplete type
ipntable.c:372: error: dereferencing pointer to incomplete type
ipntable.c:375: warning: implicit declaration of function =E2=80=98NDTA=
_RTA=E2=80=99
ipntable.c:376: error: dereferencing pointer to incomplete type
ipntable.c:376: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=
=80=99 makes pointer from integer without a cast
ipntable.c:378: error: =E2=80=98NDTA_NAME=E2=80=99 undeclared (first us=
e in this function)
ipntable.c:384: error: =E2=80=98NDTA_PARMS=E2=80=99 undeclared (first u=
se in this function)
ipntable.c:388: error: =E2=80=98NDTPA_IFINDEX=E2=80=99 undeclared (firs=
t use in this function)
ipntable.c:399: error: dereferencing pointer to incomplete type
ipntable.c:401: error: dereferencing pointer to incomplete type
ipntable.c:403: error: dereferencing pointer to incomplete type
ipntable.c:406: error: dereferencing pointer to incomplete type
ipntable.c:415: error: =E2=80=98NDTA_THRESH1=E2=80=99 undeclared (first=
 use in this function)
ipntable.c:415: error: =E2=80=98NDTA_THRESH2=E2=80=99 undeclared (first=
 use in this function)
ipntable.c:415: error: =E2=80=98NDTA_THRESH3=E2=80=99 undeclared (first=
 use in this function)
ipntable.c:416: error: =E2=80=98NDTA_GC_INTERVAL=E2=80=99 undeclared (f=
irst use in this function)
ipntable.c:440: error: =E2=80=98NDTA_CONFIG=E2=80=99 undeclared (first =
use in this function)
ipntable.c:446: error: dereferencing pointer to incomplete type
ipntable.c:447: error: dereferencing pointer to incomplete type
ipntable.c:448: error: dereferencing pointer to incomplete type
ipntable.c:454: error: dereferencing pointer to incomplete type
ipntable.c:456: error: dereferencing pointer to incomplete type
ipntable.c:461: error: dereferencing pointer to incomplete type
ipntable.c:462: error: dereferencing pointer to incomplete type
ipntable.c:464: error: dereferencing pointer to incomplete type
ipntable.c:465: error: dereferencing pointer to incomplete type
ipntable.c:481: error: =E2=80=98NDTPA_REFCNT=E2=80=99 undeclared (first=
 use in this function)
ipntable.c:485: error: =E2=80=98NDTPA_REACHABLE_TIME=E2=80=99 undeclare=
d (first use in this function)
ipntable.c:489: error: =E2=80=98NDTPA_BASE_REACHABLE_TIME=E2=80=99 unde=
clared (first use in this function)
ipntable.c:493: error: =E2=80=98NDTPA_RETRANS_TIME=E2=80=99 undeclared =
(first use in this function)
ipntable.c:502: error: =E2=80=98NDTPA_GC_STALETIME=E2=80=99 undeclared =
(first use in this function)
ipntable.c:506: error: =E2=80=98NDTPA_DELAY_PROBE_TIME=E2=80=99 undecla=
red (first use in this function)
ipntable.c:510: error: =E2=80=98NDTPA_QUEUE_LEN=E2=80=99 undeclared (fi=
rst use in this function)
ipntable.c:519: error: =E2=80=98NDTPA_APP_PROBES=E2=80=99 undeclared (f=
irst use in this function)
ipntable.c:523: error: =E2=80=98NDTPA_UCAST_PROBES=E2=80=99 undeclared =
(first use in this function)
ipntable.c:527: error: =E2=80=98NDTPA_MCAST_PROBES=E2=80=99 undeclared =
(first use in this function)
ipntable.c:536: error: =E2=80=98NDTPA_ANYCAST_DELAY=E2=80=99 undeclared=
 (first use in this function)
ipntable.c:540: error: =E2=80=98NDTPA_PROXY_DELAY=E2=80=99 undeclared (=
first use in this function)
ipntable.c:544: error: =E2=80=98NDTPA_PROXY_QLEN=E2=80=99 undeclared (f=
irst use in this function)
ipntable.c:548: error: =E2=80=98NDTPA_LOCKTIME=E2=80=99 undeclared (fir=
st use in this function)
ipntable.c:556: error: =E2=80=98NDTA_STATS=E2=80=99 undeclared (first u=
se in this function)
ipntable.c:562: error: dereferencing pointer to incomplete type
ipntable.c:563: error: dereferencing pointer to incomplete type
ipntable.c:564: error: dereferencing pointer to incomplete type
ipntable.c:569: error: dereferencing pointer to incomplete type
ipntable.c:570: error: dereferencing pointer to incomplete type
ipntable.c:571: error: dereferencing pointer to incomplete type
ipntable.c:576: error: dereferencing pointer to incomplete type
ipntable.c:577: error: dereferencing pointer to incomplete type
ipntable.c:582: error: dereferencing pointer to incomplete type
ipntable.c:583: error: dereferencing pointer to incomplete type
ipntable.c:358: warning: unused variable =E2=80=98tpb=E2=80=99
ipntable.c:357: warning: unused variable =E2=80=98tb=E2=80=99
make[1]: *** [ipntable.o] Error 1
In file included from ../include/linux/rtnetlink.h:5,
                 from ipxfrm.c:37:
/usr/include/linux/if.h:117: error: redefinition of =E2=80=98struct ifm=
ap=E2=80=99
/usr/include/linux/if.h:153: error: redefinition of =E2=80=98struct ifr=
eq=E2=80=99
/usr/include/linux/if.h:203: error: redefinition of =E2=80=98struct ifc=
onf=E2=80=99
make[1]: *** [ipxfrm.o] Error 1
make[1]: *** No rule to make target `../lib/libnetlink.a', needed by `i=
p'.
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from rtmon.c:26:
/usr/include/linux/if.h:117: error: redefinition of =E2=80=98struct ifm=
ap=E2=80=99
/usr/include/linux/if.h:153: error: redefinition of =E2=80=98struct ifr=
eq=E2=80=99
/usr/include/linux/if.h:203: error: redefinition of =E2=80=98struct ifc=
onf=E2=80=99
make[1]: *** [rtmon.o] Error 1
make[1]: Target `all' not remade because of errors.
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
/usr/include/linux/if.h:117: error: redefinition of =E2=80=98struct ifm=
ap=E2=80=99
/usr/include/linux/if.h:153: error: redefinition of =E2=80=98struct ifr=
eq=E2=80=99
/usr/include/linux/if.h:203: error: redefinition of =E2=80=98struct ifc=
onf=E2=80=99
make[1]: *** [tc_filter.o] Error 1
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from m_ipt.c:22:
/usr/include/linux/if.h:117: error: redefinition of =E2=80=98struct ifm=
ap=E2=80=99
/usr/include/linux/if.h:153: error: redefinition of =E2=80=98struct ifr=
eq=E2=80=99
/usr/include/linux/if.h:203: error: redefinition of =E2=80=98struct ifc=
onf=E2=80=99
make[1]: *** [m_ipt.o] Error 1
make[1]: *** No rule to make target `../lib/libnetlink.a', needed by `t=
c'.
make[1]: Target `all' not remade because of errors.
ssfilter.y: conflicts: 27 shift/reduce
/usr/bin/ld: cannot find -lnetlink
collect2: ld returned 1 exit status
make[1]: *** [ss] Error 1
gcc: ../lib/libnetlink.a: No such file or directory
ifstat.c: In function =E2=80=98get_nlmsg=E2=80=99:
ifstat.c:84: error: =E2=80=98IFLA_MAX=E2=80=99 undeclared (first use in=
 this function)
ifstat.c:84: error: (Each undeclared identifier is reported only once
ifstat.c:84: error: for each function it appears in.)
ifstat.c:99: warning: implicit declaration of function =E2=80=98IFLA_RT=
A=E2=80=99
ifstat.c:99: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=80=
=99 makes pointer from integer without a cast
ifstat.c:100: error: =E2=80=98IFLA_IFNAME=E2=80=99 undeclared (first us=
e in this function)
ifstat.c:100: error: =E2=80=98IFLA_STATS=E2=80=99 undeclared (first use=
 in this function)
ifstat.c:84: warning: unused variable =E2=80=98tb=E2=80=99
make[1]: *** [ifstat] Error 1
gcc: ../lib/libnetlink.a: No such file or directory
make[1]: *** [rtacct] Error 1
gcc: ../lib/libnetlink.a: No such file or directory
arpd.c: In function =E2=80=98respond_to_kernel=E2=80=99:
arpd.c:267: error: field =E2=80=98ndm=E2=80=99 has incomplete type
arpd.c:274: error: invalid application of =E2=80=98sizeof=E2=80=99 to i=
ncomplete type =E2=80=98struct ndmsg=E2=80=99=20
arpd.c:278: error: =E2=80=98NUD_STALE=E2=80=99 undeclared (first use in=
 this function)
arpd.c:278: error: (Each undeclared identifier is reported only once
arpd.c:278: error: for each function it appears in.)
arpd.c:282: error: =E2=80=98NDA_DST=E2=80=99 undeclared (first use in t=
his function)
arpd.c:283: error: =E2=80=98NDA_LLADDR=E2=80=99 undeclared (first use i=
n this function)
arpd.c: In function =E2=80=98do_one_request=E2=80=99:
arpd.c:302: error: =E2=80=98NDA_MAX=E2=80=99 undeclared (first use in t=
his function)
arpd.c:320: error: dereferencing pointer to incomplete type
arpd.c:324: error: dereferencing pointer to incomplete type
arpd.c:325: error: dereferencing pointer to incomplete type
arpd.c:326: error: dereferencing pointer to incomplete type
arpd.c:327: error: dereferencing pointer to incomplete type
arpd.c:328: error: dereferencing pointer to incomplete type
arpd.c:328: error: =E2=80=98NUD_NOARP=E2=80=99 undeclared (first use in=
 this function)
arpd.c:331: warning: implicit declaration of function =E2=80=98NDA_RTA=E2=
=80=99
arpd.c:331: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=80=99=
 makes pointer from integer without a cast
arpd.c:333: error: =E2=80=98NDA_DST=E2=80=99 undeclared (first use in t=
his function)
arpd.c:336: error: dereferencing pointer to incomplete type
arpd.c:350: error: dereferencing pointer to incomplete type
arpd.c:350: error: =E2=80=98NUD_PROBE=E2=80=99 undeclared (first use in=
 this function)
arpd.c:350: error: =E2=80=98NUD_INCOMPLETE=E2=80=99 undeclared (first u=
se in this function)
arpd.c:355: error: dereferencing pointer to incomplete type
arpd.c:388: error: dereferencing pointer to incomplete type
arpd.c:397: error: dereferencing pointer to incomplete type
arpd.c:397: error: =E2=80=98NUD_FAILED=E2=80=99 undeclared (first use i=
n this function)
arpd.c:411: error: =E2=80=98NDA_LLADDR=E2=80=99 undeclared (first use i=
n this function)
arpd.c:302: warning: unused variable =E2=80=98tb=E2=80=99
m

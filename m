From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [patch]: ipv6 tunnel for MIPv6
Date: Sat, 31 May 2003 00:38:58 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030531.003858.108351451.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi>
	<Pine.LNX.4.44.0305301735340.3584-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   ajtuomin@morphine.tml.hut.fi, lpetande@morphine.tml.hut.fi,
   jagana@us.ibm.com, kumarkr@us.ibm.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0305301735340.3584-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0305301735340.3584-200000@rhea.tcs.hut.fi> (at Fri, 30 May 2003 18:00:55 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> there was a while ago some talk about an xfrm6_tunnel driver IIRC. I don't
> know how far along the project is and what capabilities the xfrm6_tunnels
> will have, but in the mean time I have an ipv6-in-ipv6 tunnel driver
> specified in RFC 2473 to offer you. If the xfrm6_tunnels are going to
> support ipv6-in-ipv6 you also might find the code useful.

The code exists in our repository.
Kanda-san is preparing patch for xfrm6_tunnel; 
patch will soon be available.


> The tunnels are needed by MIPv6 for encapsulation and decapsulation of
> tunneled packets between the home agent and mobile node. Some proctocols
> like DHCP are also run over the virtual link between the MN and the home
> network according to the MIPv6 specification.

I'm not sure if MIP6 will use this tunnel driver.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

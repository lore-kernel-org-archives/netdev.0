From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.43
Date: Fri, 18 Oct 2002 09:56:48 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021018.095648.21063407.yoshfuji@linux-ipv6.org>
References: <20021018.021802.87011078.yoshfuji@linux-ipv6.org>
	<Pine.GSO.4.44.0210180158330.18554-100000@morphine.tml.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajtuomin@morphine.tml.hut.fi, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org, pekkas@netcore.fi,
   torvalds@transmeta.com, jagana@us.ibm.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@morphine.tml.hut.fi
In-Reply-To: <Pine.GSO.4.44.0210180158330.18554-100000@morphine.tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.44.0210180158330.18554-100000@morphine.tml.hut.fi> (at Fri, 18 Oct 2002 02:52:48 +0300 (EEST)), Ville Nuorvala <vnuorval@morphine.tml.hut.fi> says:

> >   2. Please put outer address to hardware address in dev.
> 
> The reason I haven't done this is that MAX_ADDR_LEN is just 8. Does anyone
> have any objections against changing the value to 16?
> 
> >      Note: you need to modify SIOxxx ioctls too not to overrun!
> 
> Sorry, I'm not that familiar with ioctls, I just copied the basic
> functionality from sit.c. Could you explain it a bit more thoroughly, so
> even I with my thick skull understand what the problem is?

in net/core/dev.c, there're codes to copy between dev->dev_{addr,broadcast}
and ifr_hwaddr.sa_data (points sockaddr{} sized 16).

Well, we have code for it. :-)
Please look at 
   <http://www2.linux-ipv6.org/cvsweb/usagi/kernel/linux24/net/core/dev.c.diff?r1=1.1.1.12&r2=1.4>


BTW, why don't we have SIOCGIFHWBROADCAST??

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

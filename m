From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not
 assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 18:25:17 +0900 (JST)
Message-ID: <20050210.182517.55994883.yoshfuji@linux-ipv6.org>
References: <20050210002356.500401f7.akpm@osdl.org>
	<20050210.182225.07335127.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ikebe.takashi@lab.ntt.co.jp, yoshfuji@linux-ipv6.org, davem@davemloft.net,
        akpm@osdl.org, ctindel@users.sourceforge.net, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
To: netdev@oss.sgi.com
In-Reply-To: <20050210.182225.07335127.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry for typo...

In article <20050210.182225.07335127.yoshfuji@linux-ipv6.org> (at Thu, 10 Feb 2005 18:22:25 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> So, currently, you need to do this:
> 
> # ip link set bond0 address 00:01:02:03:04:05
> # ifconfig bond0 up <= here fe80::200:ff:fe00:0/64 is assigned
                              fe80::201:02ff:fe03:0405 is assigned
> # ifenslave bond0 eth0 ...

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

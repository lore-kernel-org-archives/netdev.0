From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Fri, 16 Jan 2004 04:45:22 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.044522.45452827.yoshfuji@linux-ipv6.org>
References: <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com
In-Reply-To: <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com> (at Thu, 15 Jan 2004 11:30:25 -0800), Shirley Ma <xma@us.ibm.com> says:

> This rule would mean that any new kernel development *could* break
> something somewhere else? ;-)

Please try to avoid changing the interface as long as you can.
Please add something rather change it.

In these case, we can avoid changing the interface,
so let's avoid breaking interface.

For ipv6inetNetToMeiaTable case, it is ok to add "jiffies," 
but it wrong to change the value's context.
If you really want to "change" that, please change the name.

Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [Ipoverib] [PATCH] IPv6: Add correct padding
 to IPoIB link addr option
Date: Wed, 19 Jan 2005 18:02:12 +0900 (JST)
Message-ID: <20050119.180212.65445666.yoshfuji@linux-ipv6.org>
References: <20050119.092018.07351674.yoshfuji@linux-ipv6.org>
	<OF89EA98A0.9BCDAC57-ON87256F8E.00204D4F-65256F8E.002B4CC8@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, davem@davemloft.net,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: kumarkr@us.ibm.com
In-Reply-To: <OF89EA98A0.9BCDAC57-ON87256F8E.00204D4F-65256F8E.002B4CC8@us.ibm.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

In article <OF89EA98A0.9BCDAC57-ON87256F8E.00204D4F-65256F8E.002B4CC8@us.ibm.com> (at Wed, 19 Jan 2005 13:19:55 +0530), Krishna Kumar <kumarkr@us.ibm.com> says:

> Couple of minor comments on this :
:
> 3. I guess there is no clean way to avoid changing all consumers of ll_addr
> to not worry
>     about the padding after the length and before the LL address, but it
> would be nice if
>     that were possible (eg via the ndisc_parse_options).
> 
> Also, Dave/Yoshifuji, can't ndisc_options have just nd_opt_array[5] instead
> of nd_opt_array[7],
> with indices-1 being used to store/access the options ? In any case, I was
> expecting 6 rather
> than 7 in the current code, since there are 5 options with the array[0]
> being unused.
> 

I'll take care of both. Thank you!

--yoshfuji

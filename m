From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: [GIT PULL net-next-2.6] IPv6 Updates
Date: Wed, 02 Jul 2008 16:16:09 +0900
Message-ID: <486B2B39.9090404@miraclelinux.com>
References: <20080702.123957.75682669.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:35132 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762798AbYGBHQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 03:16:11 -0400
In-Reply-To: <20080702.123957.75682669.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi YOSHIFUJI-san

If I'm not missing something, the following code
should be out side of the for-loop.

>
> -		if (local)
> -			return local;
> +			if (local)
> +				return local;
>
> -		if (flags & RT6_LOOKUP_F_IFACE)
> -			return net->ipv6.ip6_null_entry;
> +			if (flags & RT6_LOOKUP_F_IFACE)
> +				return net->ipv6.ip6_null_entry;
> +		}
>  	}

or, it terminates for-loop on the first interface.
Sorry, I should have pointed it out the last time.


Regards,
Naohiro Ooiwa




From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: Re: Linux IPv6 Bind failure with Invalid Argument
Date: Sat, 20 Apr 2002 03:52:04 +0900
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020420035204V.yoshfuji@wide.ad.jp>
References: <F241xbWbsAyTabSMvfR0001924a@hotmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: arif7290@hotmail.com
In-Reply-To: <F241xbWbsAyTabSMvfR0001924a@hotmail.com>
List-Id: netdev.vger.kernel.org

In article <F241xbWbsAyTabSMvfR0001924a@hotmail.com> (at Fri, 19 Apr 2002 18:29:53 +0000), "Md Arif" <arif7290@hotmail.com> says:

>    Would you pls help me out in this regard. I am getting Bind failure with 
> error inValid argument Linux IPv6 machine(Kernel 2.4.7)
>    Same code works in Solaris IPv6.
>    Where is is bug?????

please set sin6_scope_id in the sockaddr_in6{}.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

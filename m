From: "Hossain, Mohammad" <m_hossain@trillium.com>
Subject: RE: Linux IPv6 Bind failure with Invalid Argument
Date: Fri, 19 Apr 2002 12:04:09 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <AA70E30319FAD411AC6E00A0C95D7ABD01EE7692@fmsmsx61.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "'YOSHIFUJI Hideaki / ????'" <yoshfuji@wide.ad.jp>, arif7290@hotmail.com
List-Id: netdev.vger.kernel.org

Hello Hideaki,
  It seems my IPv6 address has link scope only.
  What value should be put in the scope id to pass the bind call? 
  Is it because of the address has scope link???

 Thanks
 Arif

-----Original Message-----
From: yoshfuji@wide.ad.jp [mailto:yoshfuji@wide.ad.jp]
Sent: Friday, April 19, 2002 11:52 AM
To: arif7290@hotmail.com
Cc: netdev@oss.sgi.com
Subject: Re: Linux IPv6 Bind failure with Invalid Argument


In article <F241xbWbsAyTabSMvfR0001924a@hotmail.com> (at Fri, 19 Apr 2002
18:29:53 +0000), "Md Arif" <arif7290@hotmail.com> says:

>    Would you pls help me out in this regard. I am getting Bind failure
with 
> error inValid argument Linux IPv6 machine(Kernel 2.4.7)
>    Same code works in Solaris IPv6.
>    Where is is bug?????

please set sin6_scope_id in the sockaddr_in6{}.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

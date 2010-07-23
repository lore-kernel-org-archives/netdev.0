From: Stuart Sheldon <stu@actusa.net>
Subject: Re: IPv6 Anycast?
Date: Fri, 23 Jul 2010 09:54:05 -0700
Message-ID: <4C49C92D.30705@actusa.net>
References: <4C48B90B.60304@actusa.net> <alpine.DEB.1.10.1007230554240.9875@uplift.swm.pp.se> <4C491AD4.9070103@actusa.net> <alpine.DEB.1.10.1007230748380.9875@uplift.swm.pp.se> <4C49B163.8090400@actusa.net> <4C49C352.6010701@astaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Mikael Abrahamsson <swmike@swm.pp.se>, netdev@vger.kernel.org,
	Stuart Sheldon <stu@actusa.net>
To: Ulrich Weber <uweber@astaro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from internal.actusa.net ([208.83.100.16]:50443 "EHLO
	internal.actusa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab0GWQyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 12:54:18 -0400
In-Reply-To: <4C49C352.6010701@astaro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Hi Ulrich,

Thanks, that resolves half the issue. So as of right now, there is no
userspace program to add anycast addresses?

Thanks in advance,

Stu Sheldon
ACT USA


Ulrich Weber wrote:
> Hi Stuart,
> 
> you probably mean the IPV6_JOIN_ANYCAST/IPV6_LEAVE_ANYCAST socket option
> support? See the old patch documentation:
> http://lkml.indiana.edu/hypermail/linux/net/0208.3/0028.html
> 
> To remove the automatic generated IPv6 Anycast addresses, you can remove
> the routes from the local table manually:
> ip -6 route del 2607:ff38:: table local
> 
> Best regards
>  Ulrich
> 

- --
Hey nineteen Thats retha franklin, She dont remember The queen of soul,
Its hard times befallen The sole survivors, She thinks Im crazy,
But Im just growing old
               -- Steely Dan - "Hey 19 - Lyrics"
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIcBAEBCAAGBQJMSckqAAoJEFKVLITDJSGSHlEP+QHx5MZugq8US0Q5K8EwWvKM
3eOaELHz7tdNT6R3YJ1h5evcmPkj8iG8HDA65BjOghsUavZczSsZtC85azJ6lTaP
lBJdJRiyQa1b9HjnLgu4zGbRWfPyYzLstwvfWUkV7SrrWzAen7HnaMy/0+vRgOb1
MDncta1DzFjJrEwKao1qT/LbN7VVSR7BGAAlhDaJSczEfo0xXRuxpVvHEG+MHT0c
EIufckWjJ9TiaYyPALldtFOdEkmS9sqZ2ryMkgrCrL7AiuqqHhTWJgywTrCZk+1O
YPy9jZGiMd7vC1u3L34ZRDT30F6bF9LrYcwk+qM0fFPbjdjDrWhIz//G67azADeJ
Z/B9KX3UgbRt+tpjDefIR4aGX2sy2YwBNz4mPrM/eq+VGp4ATayFxs4+g5Y7kbFz
a5IsnXoqTPpyeJ3dcSVQQxXB00SA2TCc167RgN4xDFu+7ZEoUM9Bbsun8KT2BywE
LnNwnRlRmlCq9MZ31Hc+3nwpeW/+kS9xnK7GmwdRhDBLskuiQZbYdsU+t4ouga0m
ylhnVQkj7cx0l9SQLUWNwz541MOY5+/tUSZNr3n7Tjyp8J7jf1v0oj2l9BqIDBRY
EW8kfHM9QF5z79jBMTgEBPeJtZYpiN/xjToGo+Xs3RZLM0ZffCWQqpE8Sre3ZdiM
6XAaGjSwTRzmYYpblhe6
=ZWuG
-----END PGP SIGNATURE-----

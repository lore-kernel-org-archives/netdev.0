From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GSO/GRO and UDP performance
Date: Fri, 06 Sep 2013 06:07:09 -0700
Message-ID: <1378472829.31445.21.camel@edumazet-glaptop>
References: <52270659.1090208@openvpn.net>
	 <1378295631.7360.98.camel@edumazet-glaptop> <52299EDD.1030208@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: James Yonan <james@openvpn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36923 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199Ab3IFNHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 09:07:11 -0400
Received: by mail-pa0-f44.google.com with SMTP id fz6so3329018pac.17
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 06:07:11 -0700 (PDT)
In-Reply-To: <52299EDD.1030208@openvpn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 03:22 -0600, James Yonan wrote:

> So I think that playing well with GSO/GRO is essential to get speedup in 
> UDP apps because of this 43x multiplier.
> 

Thats not true. GRO cannot aggregate more than 16+1 packets.

I think we cannot aggregate UDP packets, because UDP lacks sequence
numbers, so reorders would be a problem.

You really need something that is not UDP generic.

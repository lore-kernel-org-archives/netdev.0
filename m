From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next RFC 1/2] ipv6 addrconf: extend ifa_flags to u32
Date: Mon, 11 Nov 2013 15:07:20 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73FA@saturn3.aculab.com>
References: <1384181359-23199-1-git-send-email-jiri@resnulli.us> <1384181359-23199-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>, <thaller@redhat.com>,
	<stephen@networkplumber.org>, <hannes@stressinduktion.org>,
	<vyasevich@gmail.com>, <dcbw@redhat.com>
To: "Jiri Pirko" <jiri@resnulli.us>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55079 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754091Ab3KKPKZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 10:10:25 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09594-06 for <netdev@vger.kernel.org>;
 Mon, 11 Nov 2013 15:10:22 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1384181359-23199-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> --- a/include/net/if_inet6.h
> +++ b/include/net/if_inet6.h
> @@ -51,7 +51,7 @@ struct inet6_ifaddr {
>  	int			state;
> 
>  	__u8			dad_probes;
> -	__u8			flags;
> +	__u32			flags;
> 
>  	__u16			scope;

That is adding a lot of padding.

	David

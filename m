From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] xfrm: use ISO C standard for array in linux/xfrm.h
Date: Wed, 17 Oct 2012 11:03:13 +0200
Message-ID: <507E7451.7020906@6wind.com>
References: <1350402153-3889-1-git-send-email-nicolas.dichtel@6wind.com> <20121017054343.GA12671@secunet.com> <507E6362.1080009@6wind.com> <20121017082731.GB12671@secunet.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	davem@davemloft.net
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52237 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234Ab2JQJDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 05:03:17 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so3906873eek.19
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 02:03:16 -0700 (PDT)
In-Reply-To: <20121017082731.GB12671@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/10/2012 10:27, Steffen Klassert a =E9crit :
> On Wed, Oct 17, 2012 at 09:50:58AM +0200, Nicolas Dichtel wrote:
>> We got a problem with "ip xfrm state add" when compiled with gcc 4.4=
=2E6.
>> Error was "*** buffer overflow detected ***: ip terminated", because
>> when we try to copy the key in struct xfrm_algo, the function
>> strncpy() calls some builtin checks about the size of the
>> destination buffer, which is 0. With the standard notation, there is
>> no problem.
>
> This is likely to be a gcc FORITFY bug. Try to build iproute2 with
> the -D_FORTIFY_SOURCE=3D0 flag.
>
Right, it works. Thank you.

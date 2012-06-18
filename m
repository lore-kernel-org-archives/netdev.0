From: Fan Du <fan.du@windriver.com>
Subject: Re: [XFRM][RFC v1] Fix unexpected SA hard expiration after setting
 new date
Date: Mon, 18 Jun 2012 16:53:05 +0800
Message-ID: <4FDEEC71.50302@windriver.com>
References: <1340007856-27651-1-git-send-email-fan.du@windriver.com> <20120618084021.GA24902@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<fdu@windriver.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50506 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab2FRIv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 04:51:58 -0400
In-Reply-To: <20120618084021.GA24902@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012=E5=B9=B406=E6=9C=8818=E6=97=A5 16:40, Herbert Xu wrote:
> On Mon, Jun 18, 2012 at 04:24:15PM +0800, fan.du wrote:
>>
>> So, could you please give your comments on this?
>
> Well, this used to work back when we were using relative time
> instead of absolute time.  Then someone came along and changed
> it for suspend/resume.
>
> I didn't like this new behaviour but Dave convinced me that
> it is a good thing :)
>

One of our custom complained the networking down when changing date,
even it's only less than 10 seconds, but they complain anyway:)
So it probably hurts much in practice for tel comm company.


> I guess I can live with your workaround if Dave is happy with
> it.  But IMHO we should just go back to relative time and fix
> the suspend/resume user-space scripts instead.

Ok, let's see what Dave will say about this.
And thanks for your comments.

>
> Cheers,

--=20

Love each day!
--fan

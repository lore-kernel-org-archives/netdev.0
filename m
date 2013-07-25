From: Andrew Collins <bsderandrew@gmail.com>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Thu, 25 Jul 2013 15:46:58 -0600
Message-ID: <CAKTPYJReVfF85wvpbjCF1XREoh3+wzC1baxibZNE1auexcgigA@mail.gmail.com>
References: <20130723220221.GP10216@zirkel.wertarbyte.de>
	<20130724021420.GA10670@order.stressinduktion.org>
	<20130725162931.GX10216@zirkel.wertarbyte.de>
	<20130725181712.GB24007@order.stressinduktion.org>
	<20130725182818.GZ10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:44931 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab3GYVrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 17:47:03 -0400
Received: by mail-vb0-f52.google.com with SMTP id f12so787538vbg.11
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 14:46:59 -0700 (PDT)
In-Reply-To: <20130725182818.GZ10216@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 12:28 PM, Stefan Tomanek
<stefan.tomanek@wertarbyte.de> wrote:
> Dies schrieb Hannes Frederic Sowa (hannes@stressinduktion.org):
>
>> > I however did like the idea of adding IPv6 support, so I did -
>> > I'll post the new patch later on.
>>
>> Cool, thanks.
>
> I've just completed the patch and sent it to the list, and I also placed the
> changes in my github account, just in case anyone wants to take a quick peek:
> https://github.com/wertarbyte/linux/compare/prefixlength
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

> +  if (arg->result) { ...

This NULL check seems unnecessary (fib_table_lookup doesn't check).

I like the idea, but I agree with Hannes that it'd be nice to split
this out into a fib constraint callback.

From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 tunnel name parsing
Date: Thu, 17 Sep 2015 23:10:57 +0300
Message-ID: <20150917201057.GA32635@angus-think.lan>
References: <CAK8ArgO8mWN657smVDuCRHQVKScnBM1K9VP93e-YY+hf2sdwyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wilhelm Wijkander <lists@0x5e.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33113 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbIQUOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 16:14:16 -0400
Received: by wiclk2 with SMTP id lk2so38759177wic.0
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 13:14:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAK8ArgO8mWN657smVDuCRHQVKScnBM1K9VP93e-YY+hf2sdwyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 09:55:29PM +0200, Wilhelm Wijkander wrote:
> Hi,
> 
> I'm trying to create a sit tunnel called "hel": ip tun add hel mode
> sit remote 10.200.0.2 local 10.200.1.2 ttl 255, however it seems like
> this is interpreted as the help argument and I get the usage text. Is
> there a way to escape names that I've missed, or is this an error
> somewhere in argv parsing?
> 
> (I'm not subscribed, so a cc would be appreciated)
> Thanks,
> Wilhelm
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi Wilhelm,

You can use 'name' before 'hel' like:

    $ ip tun add name hel mode sit remote 10.200.0.2 local 10.200.1.2 ttl 255

and it should work, actually I just tried and it works.

Regards,
Vadim Kochan

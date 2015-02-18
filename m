From: Tom Herbert <therbert@google.com>
Subject: Re: Setting RPS affinities from network driver
Date: Wed, 18 Feb 2015 07:44:35 -0800
Message-ID: <CA+mtBx9qHdEeXmEGbbWSr_OL3aAQJ37eTbC0mUY_XrTNoZ6iXw@mail.gmail.com>
References: <CA+sq2CeC89YfaTM18JR9dFOoNAbohGk=gFXSkM_4q2oySB12GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:40477 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbbBRPof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 10:44:35 -0500
Received: by iebtr6 with SMTP id tr6so2143703ieb.7
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 07:44:35 -0800 (PST)
In-Reply-To: <CA+sq2CeC89YfaTM18JR9dFOoNAbohGk=gFXSkM_4q2oySB12GA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2015 at 10:16 PM, Sunil Kovvuri <sunil.kovvuri@gmail.com> wrote:
> Hi,
>
> I am writing a network driver for a multicore SOC with a on-board
> network interface and would like to set RPS affinities from driver by
> default. So that the network performance is good with whatever driver
> supplied. Ofcourse these can be further adjusted from userspace
> anyways.
>
> Is there a way to set RPS settings from driver itself ?
> The only issue i am seeing is while setting 'rps_needed' key.
>
There is nothing to prevent this, but it would be really cool to make
this into a library function that drivers can call to initialize RPS
in some sane way (you might want to look at cpu_rmap).

> static_key_slow_inc(&rps_needed);
>
> Currently this is not exported, so having issues while compiling
> driver as module.
>
> If i export this symbol, will it be acceptable ?
>
Seems okay to me.

Thanks,
Tom

>
> Thanks,
> Sunil.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: ixp4xx_hss. Little bug in hss_init_one
Date: Fri, 5 Dec 2008 08:56:27 +0100
Message-ID: <b0438a630812042356l313258a8o870decd8ce1d5390@mail.gmail.com>
References: <b0438a630811260913t638343a4i5576292b367c5dc2@mail.gmail.com>
	 <m38wqvznp4.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:45373 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbYLEH4a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 02:56:30 -0500
Received: by an-out-0708.google.com with SMTP id d40so1775155and.1
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2008 23:56:27 -0800 (PST)
In-Reply-To: <m38wqvznp4.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My pleasure.

2008/12/4 Krzysztof Halasa <khc@pm.waw.pl>:
> Hi,
>
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>> I have found that platform_set_drvdata is not correctly called if we
>> have an error in requesting npe. Am I right?
>
> Definitely. Though I will just move platform_set_drvdata() past
> npe_request() (and register_hdlc_device()).
>
> Thanks for spotting this bug.
> --
> Krzysztof Halasa
>

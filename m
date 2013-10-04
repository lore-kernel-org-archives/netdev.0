From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] dev: add support of flag IFF_NOPROC
Date: Fri, 04 Oct 2013 14:07:00 +0200
Message-ID: <524EAF64.8000801@6wind.com>
References: <1380806905-4461-1-git-send-email-nicolas.dichtel@6wind.com>	<20131003104627.411f5cc4@nehalam.linuxnetplumber.net> <20131003.150947.2179820478039260398.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:51070 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754310Ab3JDMHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 08:07:04 -0400
Received: by mail-wi0-f175.google.com with SMTP id ez12so1505324wid.2
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 05:07:02 -0700 (PDT)
In-Reply-To: <20131003.150947.2179820478039260398.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/10/2013 21:09, David Miller a =E9crit :
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 3 Oct 2013 10:46:27 -0700
>
>> What about speeding up proc or sysfs? Or providing a bulk create/des=
troy.
>
> +1 +1 +1
>
> This will benefit more people than the just the envisioned users for
> this IFF_NOPROC thing.
>
> I really don't want to take the IFF_NOPROC approach.
>
Of course optimizing /proc and /sysfs is a good option, but any optimiz=
ations
will never be as fast as disabling them for some well known netdevices.

Note also that the memory consumption is significantly less with this f=
lag:
for 20000 dummy interfaces:
without the flag: 463,84Mo
with the flag: 297,45Mo
the gain is 166Mo (35%)

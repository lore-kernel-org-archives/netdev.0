From: Veaceslav Falico <darkmag@gmail.com>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Thu, 1 Aug 2013 22:21:25 +0200
Message-ID: <CAE3RKN=AoevKmRDewpmm8TjDasN8k=J4Sny8gCCv6dbOXwHADQ@mail.gmail.com>
References: <20130801121142.GA444@www.manty.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Santiago Garcia Mantinan <manty@manty.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:65067 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab3HAUVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 16:21:46 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so2414697pdj.35
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 13:21:45 -0700 (PDT)
In-Reply-To: <20130801121142.GA444@www.manty.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 1, 2013 at 2:11 PM, Santiago Garcia Mantinan
<manty@manty.net> wrote:
> Hi!
...snip...
>
> This is the setup on the bonding interface.
>
> auto bond0
> iface bond0 inet static
>         address 192.168.1.2
>         netmask 255.255.255.0
>         bond-slaves eth0.1002
>         bond-mode active-backup
>         bond-arp_validate 0

Could you please try with arp_validate=1?

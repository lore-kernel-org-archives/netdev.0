From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Fri, 10 Apr 2015 07:27:25 -0300
Message-ID: <CAOMZO5BoYo_wvmxS0EN0M6CaLWk-rvCw6hpmmwvGNwAG=1vkMQ@mail.gmail.com>
References: <5525571D.7060909@free.fr>
	<5525658D.7000709@gmail.com>
	<5526662C.8010509@free.fr>
	<5526806E.5020309@zonque.org>
	<55268EF3.7050301@free.fr>
	<5526993F.1010304@free.fr>
	<5526B608.2080504@gmail.com>
	<5526CA87.2070204@free.fr>
	<5526CC5A.1080504@gmail.com>
	<5526D359.1050202@free.fr>
	<CAOMZO5DhQnOtSN_bmh7JsCf=GsFats3pqpH4w+p1XWtAF=4LmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Mack <daniel@zonque.org>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:33931 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735AbbDJK11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 06:27:27 -0400
Received: by lbcga7 with SMTP id ga7so10291181lbc.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 03:27:25 -0700 (PDT)
In-Reply-To: <CAOMZO5DhQnOtSN_bmh7JsCf=GsFats3pqpH4w+p1XWtAF=4LmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 9, 2015 at 7:31 PM, Fabio Estevam <festevam@gmail.com> wrote:
> On Thu, Apr 9, 2015 at 4:30 PM, Mason <slash.tmp@free.fr> wrote:
>
>> Am I the only having problems with the AR8035? :-(
>>
>> The standard driver works for everyone but me?
>
> Works well on a imx6q-hummingboard:
>
> fec 2188000.ethernet eth0: Freescale FEC PHY driver [Atheros 8035
> ethernet] (mii_bus:phy_addr=2188000.ethernet:00, irq=-1)

Forgot to point out that we also have a 8035 fixup in
arch/arm/mach-imx/mach-imx6q.c. Search for ar8035_phy_fixup().

Regards,

Fabio Estevam

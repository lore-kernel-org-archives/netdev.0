From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: Re: [PATCH net-next 3/6] net: use core MTU range checking in WAN drivers
Date: Fri, 21 Oct 2016 14:04:06 +0200
Message-ID: <m37f916h8p.fsf@t19.piap.pl>
References: <20161019023333.15760-1-jarod@redhat.com>
        <20161019023333.15760-4-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Krzysztof Halasa <khc@pm.waw.pl>,
        Jan Yenya Kasprzak <kas@fi.muni.cz>,
        Francois Romieu <romieu@fr.zoreil.com>,
        Kevin Curtis <kevin.curtis@farsite.co.uk>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161019023333.15760-4-jarod@redhat.com> (Jarod Wilson's message
        of "Tue, 18 Oct 2016 22:33:30 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarod Wilson <jarod@redhat.com> writes:

> - set min/max_mtu in all hdlc drivers, remove hdlc_change_mtu
> - sent max_mtu in lec driver, remove lec_change_mtu

>  drivers/net/wan/c101.c            |  1 -
>  drivers/net/wan/hdlc.c            | 11 ++---------
>  drivers/net/wan/hdlc_fr.c         |  3 ++-
>  drivers/net/wan/ixp4xx_hss.c      |  1 -
>  drivers/net/wan/n2.c              |  1 -
>  drivers/net/wan/pc300too.c        |  1 -
>  drivers/net/wan/pci200syn.c       |  1 -
>  drivers/net/wan/wanxl.c           |  1 -
>  include/linux/hdlc.h              |  2 --

Acked-by: Krzysztof Halasa <khalasa@piap.pl>
-- 
Krzysztof Halasa

Industrial Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland

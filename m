From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [Patch net] mlx4: set csum_complete_sw bit when fixing complete
 csum
Date: Wed, 29 Jun 2016 17:23:18 +0300
Message-ID: <ca13266f-4cd9-3ac1-9092-9142475cbce9@gmail.com>
References: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com>
 <CAM_iQpUBQqV3oC7=WqyNtu58HmbJbV29yz6_r_ib6XqWpw7VGg@mail.gmail.com>
 <CAJ3xEMhgyvq2_ZsipQ_iFcC6Ef65hj2rkZ0U5scGvj4-=eNkLA@mail.gmail.com>
 <CAM_iQpVPp3YYpfjGmYzBi=i1ONeOT+eLd-P67KuGpHGUmcCZNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Carol L Soto <clsoto@us.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37480 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbcF2OXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 10:23:24 -0400
Received: by mail-wm0-f45.google.com with SMTP id a66so76385643wme.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 07:23:24 -0700 (PDT)
In-Reply-To: <CAM_iQpVPp3YYpfjGmYzBi=i1ONeOT+eLd-P67KuGpHGUmcCZNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

> See below. Does commit f8c6455bb04b944edb69e rely on any firmware
> change to get an expected checksum?
>
> $ lspci -nn | grep -i mellanox
> 82:00.0 Ethernet controller [0200]: Mellanox Technologies MT27500
> Family [ConnectX-3] [15b3:1003]
>
> $ ethtool -i eth0
> driver: mlx4_en
> version: 2.2-1 (Feb 2014)
> firmware-version: 2.33.5220
> bus-info: 0000:82:00.0
I used same HW and FW, but was not able to reproduce.
I have kernel HEAD of net-next: 8a79813c1401 net: ethernet: dwc_eth_qos: 
use phy_ethtool_{get|set}_link_ksettings

I ran regular ping, and ping6. Checksum complete counter increases, but 
no warnings in dmesg.
What kernel do you use? Does it repro on latest net-next?

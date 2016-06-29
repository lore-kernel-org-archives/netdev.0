From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [Patch net] mlx4: set csum_complete_sw bit when fixing complete csum
Date: Wed, 29 Jun 2016 17:33:47 +0300
Message-ID: <CAJ3xEMhYvFk66ZPPb3qtPM7NhPbCtAvPWSTKe528bO-k1QUjJA@mail.gmail.com>
References: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com>
 <CAM_iQpUBQqV3oC7=WqyNtu58HmbJbV29yz6_r_ib6XqWpw7VGg@mail.gmail.com>
 <CAJ3xEMhgyvq2_ZsipQ_iFcC6Ef65hj2rkZ0U5scGvj4-=eNkLA@mail.gmail.com>
 <CAM_iQpVPp3YYpfjGmYzBi=i1ONeOT+eLd-P67KuGpHGUmcCZNA@mail.gmail.com> <ca13266f-4cd9-3ac1-9092-9142475cbce9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Carol L Soto <clsoto@us.ibm.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:35982 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090AbcF2Odt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 10:33:49 -0400
Received: by mail-ob0-f180.google.com with SMTP id mu6so28125714obc.3
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 07:33:48 -0700 (PDT)
In-Reply-To: <ca13266f-4cd9-3ac1-9092-9142475cbce9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016 at 5:23 PM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
> Hi Cong,
>
>> See below. Does commit f8c6455bb04b944edb69e rely on any firmware
>> change to get an expected checksum?
>>
>> $ lspci -nn | grep -i mellanox
>> 82:00.0 Ethernet controller [0200]: Mellanox Technologies MT27500
>> Family [ConnectX-3] [15b3:1003]
>>
>> $ ethtool -i eth0
>> driver: mlx4_en
>> version: 2.2-1 (Feb 2014)
>> firmware-version: 2.33.5220
>> bus-info: 0000:82:00.0
>
> I used same HW and FW, but was not able to reproduce.
> I have kernel HEAD of net-next: 8a79813c1401 net: ethernet: dwc_eth_qos: use
> phy_ethtool_{get|set}_link_ksettings
>
> I ran regular ping, and ping6. Checksum complete counter increases, but no
> warnings in dmesg.
> What kernel do you use? Does it repro on latest net-next?

Also, can you share us somehow (e.g send to us as attachment, your
compressed .config)

Or.

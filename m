From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] mlx4: set csum_complete_sw bit when fixing complete csum
Date: Tue, 28 Jun 2016 09:52:15 -0700
Message-ID: <CAM_iQpVPp3YYpfjGmYzBi=i1ONeOT+eLd-P67KuGpHGUmcCZNA@mail.gmail.com>
References: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com>
 <CAM_iQpUBQqV3oC7=WqyNtu58HmbJbV29yz6_r_ib6XqWpw7VGg@mail.gmail.com> <CAJ3xEMhgyvq2_ZsipQ_iFcC6Ef65hj2rkZ0U5scGvj4-=eNkLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Carol L Soto <clsoto@us.ibm.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:36045 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbcF1Qwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 12:52:35 -0400
Received: by mail-qk0-f170.google.com with SMTP id z142so16126474qkb.3
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 09:52:35 -0700 (PDT)
In-Reply-To: <CAJ3xEMhgyvq2_ZsipQ_iFcC6Ef65hj2rkZ0U5scGvj4-=eNkLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 7:30 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> Wow, can you please report us the exact card type (lspci -nn | grep -i
> mellanox) and  firmware version (ethtool -i $DEV)

See below. Does commit f8c6455bb04b944edb69e rely on any firmware
change to get an expected checksum?

$ lspci -nn | grep -i mellanox
82:00.0 Ethernet controller [0200]: Mellanox Technologies MT27500
Family [ConnectX-3] [15b3:1003]

$ ethtool -i eth0
driver: mlx4_en
version: 2.2-1 (Feb 2014)
firmware-version: 2.33.5220
bus-info: 0000:82:00.0

From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: [PATCH] net: ipv4: current group_info should be put after using.
Date: Sun, 11 May 2014 23:55:22 +0200
Message-ID: <20140511215521.GA12224@mguzik.redhat.com>
References: <1397493045.2575.8.camel@wxm-ubuntu>
 <20140413.225407.1762639913754561393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: xiaoming.wang@intel.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	dongxing.zhang@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140413.225407.1762639913754561393.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 13, 2014 at 10:54:07PM -0400, David Miller wrote:
> From: "Wang, Xiaoming" <xiaoming.wang@intel.com>
> Date: Mon, 14 Apr 2014 12:30:45 -0400
> 
> > Plug a group_info refcount leak in ping_init.
> > group_info is only needed during initialization and 
> > the code failed to release the reference on exit.
> > While here move grabbing the reference to a place 
> > where it is actually needed.
> > 
> > Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
> > Signed-off-by: Zhang Dongxing <dongxing.zhang@intel.com>
> > Signed-off-by: xiaoming wang <xiaoming.wang@intel.com>
> 
> Applied and queued up for -stable, thanks.

I see this only made its way to 3.12 kernel, what is holding up inclusion
in other kernels? (or maybe this question should be directed at someone
else?)

The bug was introduced with:
commit c319b4d76b9e583a5d88d6bf190e079c4e43213d
Author: Vasiliy Kulikov <segoon@openwall.com>
Date:   Fri May 13 10:01:00 2011 +0000
    net: ipv4: add IPPROTO_ICMP socket kind

starting with 3.0.

Thanks,
-- 
Mateusz Guzik

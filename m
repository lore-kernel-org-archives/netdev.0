From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: current group_info should be put after
 using.
Date: Sun, 13 Apr 2014 22:54:07 -0400 (EDT)
Message-ID: <20140413.225407.1762639913754561393.davem@davemloft.net>
References: <1397493045.2575.8.camel@wxm-ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mguzik@redhat.com,
	chuansheng.liu@intel.com, dongxing.zhang@intel.com
To: xiaoming.wang@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397493045.2575.8.camel@wxm-ubuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Wang, Xiaoming" <xiaoming.wang@intel.com>
Date: Mon, 14 Apr 2014 12:30:45 -0400

> Plug a group_info refcount leak in ping_init.
> group_info is only needed during initialization and 
> the code failed to release the reference on exit.
> While here move grabbing the reference to a place 
> where it is actually needed.
> 
> Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
> Signed-off-by: Zhang Dongxing <dongxing.zhang@intel.com>
> Signed-off-by: xiaoming wang <xiaoming.wang@intel.com>

Applied and queued up for -stable, thanks.

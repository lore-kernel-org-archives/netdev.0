From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: current group_info should be put after
 using.
Date: Thu, 10 Apr 2014 23:11:43 -0400 (EDT)
Message-ID: <20140410.231143.457143731030572105.davem@davemloft.net>
References: <1397232638.20759.28.camel@wxm-ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	dongxing.zhang@intel.com
To: xiaoming.wang@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397232638.20759.28.camel@wxm-ubuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Wang, Xiaoming" <xiaoming.wang@intel.com>
Date: Fri, 11 Apr 2014 12:10:38 -0400

> +EXIT:

Do not use all CAPS names for local labels.

Make the label, in lower case, say something about
what state needs to be released at that point.

Something like "out_release_group:"

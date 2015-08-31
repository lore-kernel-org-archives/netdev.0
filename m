From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IGMP: Inhibit reports for local multicast groups -
 DOCUMENT
Date: Mon, 31 Aug 2015 12:30:52 -0700 (PDT)
Message-ID: <20150831.123052.2026420716334269701.davem@davemloft.net>
References: <d208b6d6990faa29d022fbdc03bd9968a458e250.1441016151.git.pdowney@brocade.com>
	<dff26e321e8af946d1dd1899eef1327e64a517a3.1441016151.git.pdowney@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: pdowney@brocade.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dff26e321e8af946d1dd1899eef1327e64a517a3.1441016151.git.pdowney@brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philip Downey <pdowney@brocade.com>
Date: Mon, 31 Aug 2015 11:30:38 +0100

> Document the addition of a new sysctl variable which controls the
> generation of IGMP reports for link local multicast groups in the
> 224.0.0.X range.
> 
> IGMP reports for local multicast groups can now be optionally
> inhibited by setting the value to zero e.g.:
> echo 0 > /proc/sys/net/ipv4/igmp_link_local_mcast_reports
> 
> To retain backwards compatibility the previous behaviour is retained
> by default on system boot or reverted by setting the value back to
> non-zero.
> 
> Signed-off-by: Philip Downey <pdowney@brocade.com>

Applied, thanks.

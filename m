From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: disallow UFO for sockets with SO_NO_CHECK
 option
Date: Mon, 11 Jan 2016 17:42:05 -0500 (EST)
Message-ID: <20160111.174205.202764956086980022.davem@davemloft.net>
References: <20160111065030.F3FFCA0EF1@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	hannes@stressinduktion.org, shannon.nelson@intel.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160111065030.F3FFCA0EF1@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon, 11 Jan 2016 07:50:30 +0100 (CET)

> Commit acf8dd0a9d0b ("udp: only allow UFO for packets from SOCK_DGRAM
> sockets") disallows UFO for packets sent from raw sockets. We need to do
> the same also for SOCK_DGRAM sockets with SO_NO_CHECK options, even if
> for a bit different reason: while such socket would override the
> CHECKSUM_PARTIAL set by ip_ufo_append_data(), gso_size is still set and
> bad offloading flags warning is triggered in __skb_gso_segment().
> 
> In the IPv6 case, SO_NO_CHECK option is ignored but we need to disallow
> UFO for packets sent by sockets with UDP_NO_CHECK6_TX option.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> Tested-by: Shannon Nelson <shannon.nelson@intel.com>

Applied and queued up for -stable, thanks Michal.

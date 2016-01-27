From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net:Add sysctl_tcp_sg_max_skb_frags
Date: Wed, 27 Jan 2016 15:13:20 -0500 (EST)
Message-ID: <20160127.151320.1372943289286781199.davem@davemloft.net>
References: <568F87AC.60405@oracle.com>
	<1453900829-3384-1-git-send-email-hans.westgaard.ry@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	haakon.bugge@oracle.com
To: hans.westgaard.ry@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453900829-3384-1-git-send-email-hans.westgaard.ry@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Date: Wed, 27 Jan 2016 14:20:29 +0100

> Devices may have limits on the number of fragments in an skb they support.

Then this belongs as a global networking setting not a protocol
specfic one.

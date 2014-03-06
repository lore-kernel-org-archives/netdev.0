From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6 exthedrs offload registration fixed
Date: Thu, 06 Mar 2014 16:37:22 -0500 (EST)
Message-ID: <20140306.163722.179347273947121001.davem@davemloft.net>
References: <1394001008-2444-1-git-send-email-anton@swortex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: anton@swortex.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394001008-2444-1-git-send-email-anton@swortex.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Nayshtut <anton@swortex.com>
Date: Wed,  5 Mar 2014 08:30:08 +0200

> Without this fix, ipv6_exthdrs_offload_init doesn't register IPPROTO_DSTOPTS
> offload, but returns 0 (as the IPPROTO_ROUTING registration actually succeeds).
> 
> This then causes the ipv6_gso_segment to drop IPv6 packets with IPPROTO_DSTOPTS
> header.
> 
> The issue detected and the fix verified by running MS HCK Offload LSO test on
> top of QEMU Windows guests, as this test sends IPv6 packets with
> IPPROTO_DSTOPTS.
> 
> Signed-off-by: Anton Nayshtut <anton@swortex.com>

Can't believe this was broken so obviously for so long :-)

Applied and queued up for -stable, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix the upper MTU limit in ipv6 GRE tunnel
Date: Mon, 07 Oct 2013 12:53:26 -0400 (EDT)
Message-ID: <20131007.125326.895480090584703586.davem@davemloft.net>
References: <1380880333-3546-1-git-send-email-ou.ghorbel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ou.ghorbel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380880333-3546-1-git-send-email-ou.ghorbel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Date: Fri,  4 Oct 2013 10:52:13 +0100

> Unlike ipv4, the struct member hlen holds the length of the GRE and ipv6
> headers. This length is also counted in dev->hard_header_len.
> Perhaps, it's more clean to modify the hlen to count only the GRE header
> without ipv6 header as the variable name suggest, but the simple way to fix
> this without regression risk is simply modify the calculation of the limit
> in ip6gre_tunnel_change_mtu function.
> Verified in kernel version v3.11.
> 
> Signed-off-by: Oussama Ghorbel <ou.ghorbel@gmail.com>

Please resubmit this with a proper Subject line.

It should be "[PATCH] " then a legitimate subsystem prefix.
In this case "ipv6: " would be appropriate.  And then
the "ipv6" in your existing Subject text is redundant so
can be removed.

Thanks.

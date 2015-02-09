From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: Wrong type passed to %pIS
Date: Sun, 08 Feb 2015 17:15:02 -0800 (PST)
Message-ID: <20150208.171502.1797960070992248341.davem@davemloft.net>
References: <1423275451-3663-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423275451-3663-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Sat,  7 Feb 2015 03:17:31 +0100

> src_ip is a pointer to a union vxlan_addr, one member of which is a
> struct sockaddr. Passing a pointer to src_ip is wrong; one should pass
> the value of src_ip itself. Since %pIS formally expects something of
> type struct sockaddr*, let's pass a pointer to the appropriate union
> member, though this of course doesn't change the generated code.
> 
> Fixes: e4c7ed415387 ("vxlan: add ipv6 support")
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied, thanks.

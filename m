From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: ip_check_defrag should correctly check return
 value of skb_copy_bits
Date: Fri, 20 Feb 2015 15:23:17 -0500 (EST)
Message-ID: <20150220.152317.2246116638858595617.davem@davemloft.net>
References: <1424169226-30112-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: al.drozdov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424169226-30112-1-git-send-email-al.drozdov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Drozdov <al.drozdov@gmail.com>
Date: Tue, 17 Feb 2015 13:33:46 +0300

> skb_copy_bits() returns zero on success and negative value on error,
> so it is needed to invert the condition in ip_check_defrag().
> 
> Fixes: 1bf3751ec90c ("ipv4: ip_check_defrag must not modify skb before unsharing")
> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>

Applied and queued up for -stable, thanks.

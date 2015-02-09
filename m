From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2] net: Mellanox: Delete unnecessary checks before the
 function call "vunmap"
Date: Mon, 09 Feb 2015 14:10:18 -0800 (PST)
Message-ID: <20150209.141018.2220346219639672419.davem@redhat.com>
References: <54D22B29.3020200@users.sourceforge.net>
	<20150205.003404.261962007607296519.davem@davemloft.net>
	<54D88A26.2060307@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli@mellanox.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D88A26.2060307@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 09 Feb 2015 11:21:26 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 9 Feb 2015 11:10:41 +0100
> 
> The vunmap() function performs also input parameter validation.
> Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> Acked-by: Eli Cohen <eli@mellanox.com>

Applied.

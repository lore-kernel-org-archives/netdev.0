From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ipx: correct return type of ipxrtr_delete
Date: Tue, 16 May 2006 15:08:01 -0700 (PDT)
Message-ID: <20060516.150801.60939020.davem@davemloft.net>
References: <20060516201238.GM10143@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, acme@conectiva.com.br, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55999
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932199AbWEPWIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 18:08:51 -0400
To: adobriyan@gmail.com
In-Reply-To: <20060516201238.GM10143@mipter.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 17 May 2006 00:12:38 +0400

> A single caller passes __u32. Inside function "net" is compared with
> __u32 (__be32 really, just wasn't annotated).
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, but I had to fix your changelog, you're fixing the
"argument" type not the "return" type. :)

Thanks.


From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/socket.c: unexport move_addr_to_kernel
Date: Thu, 02 Jun 2005 13:14:28 -0700 (PDT)
Message-ID: <20050602.131428.28787855.davem@davemloft.net>
References: <20050530205647.GW10441@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: bunk@stusta.de
In-Reply-To: <20050530205647.GW10441@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Mon, 30 May 2005 22:56:47 +0200

> I didn't find any modular usage in the kernel.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Yes, but as a part of the socket kernel API, I could
definitely see some out-of-tree code legitimately
using this interface.  Let's keep it around for now.

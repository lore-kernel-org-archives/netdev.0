From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: add mode parameter to tcp_proc_register
Date: Fri, 23 Jun 2017 00:27:58 -0400 (EDT)
Message-ID: <20170623.002758.1129050083018969879.davem@davemloft.net>
References: <20170623014028.28257-1-colona@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colona@arista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170623014028.28257-1-colona@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Delalande <colona@arista.com>
Date: Thu, 22 Jun 2017 18:40:27 -0700

> This will be used to create a proc file that regular users cannot read.
> 
> Signed-off-by: Ivan Delalande <colona@arista.com>

/proc is deprecated.

Export this information via inet_diag.

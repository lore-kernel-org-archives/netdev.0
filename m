From: David Miller <davem@davemloft.net>
Subject: Re: [NETROM] Drop lock before calling nr_destroy_socket
Date: Mon, 10 Jul 2006 20:21:15 -0700 (PDT)
Message-ID: <20060710.202115.62655862.davem@davemloft.net>
References: <20060710232545.GA8866@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: ralf@linux-mips.org
In-Reply-To: <20060710232545.GA8866@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 11 Jul 2006 00:25:45 +0100

> nr_destroy_socket takes the socket lock itself so it should better be
> called with the socket unlocked.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.

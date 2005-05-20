From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Super TSO
Date: Thu, 19 May 2005 18:28:21 -0700 (PDT)
Message-ID: <20050519.182821.71087031.davem@davemloft.net>
References: <20050519.175542.07642115.davem@davemloft.net>
	<200505200125.j4K1PaVG015780@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: leonid.grossman@neterion.com
In-Reply-To: <200505200125.j4K1PaVG015780@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Leonid Grossman" <leonid.grossman@neterion.com>
Date: Thu, 19 May 2005 18:25:35 -0700

> Yes, I think I'm actually with you. As long as each page is physically
> continuous and therefore requires one descriptor per page, the total
> number of descriptors per packet will be only 64K / PAGE_SIZE (plus
> some for headers), and this is fully manageable from a NIC
> prospective.

Yes, that is exactly what happens.

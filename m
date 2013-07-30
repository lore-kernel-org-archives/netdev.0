From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: detect and prevent kernel panic from a possible
 faulty hardware
Date: Tue, 30 Jul 2013 16:19:06 -0700 (PDT)
Message-ID: <20130730.161906.1898764862564749288.davem@davemloft.net>
References: <1374957354-10142-1-git-send-email-sam8641@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlindner@marvell.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sam8641@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374957354-10142-1-git-send-email-sam8641@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Williams <sam8641@gmail.com>
Date: Sat, 27 Jul 2013 15:35:54 -0500

> A possible faulty hardware might interrupt with a status of 0xffffffff which
> may kernel panic if sky2 driver tries to handle it. Detecting this problem
> may avoid kernel panic.
> 
> Signed-off-by: Samuel Williams <sam8641@gmail.com>

Sure, but then the device is basically just going to stop.

I think this change needs to be more comprehensive, for example it
needs to fully reset the device and try to get it operational again.

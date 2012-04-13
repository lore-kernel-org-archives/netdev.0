From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]Fix misplaces parenthesis in virtio_net.c
Date: Fri, 13 Apr 2012 11:05:52 -0400 (EDT)
Message-ID: <20120413.110552.522790652681369943.davem@davemloft.net>
References: <20120409171415.4c49c96a@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: just.for.lkml@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120409171415.4c49c96a@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Torsten Kaiser <just.for.lkml@googlemail.com>
Date: Mon, 9 Apr 2012 17:14:15 +0200

> Commit 2e57b79ccef1ff1422fdf45a9b28fe60f8f084f7 misplaced its
> parenthesis and now tx_fifo_errors will only be incremented if an
> ENOMEM error is not written to the syslog.
> 
> Correct the parenthesis and indentation to the original goal of
> counting all non ENOMEM errors and ratelimiting only the messages.
> 
> Signed-of-by: Torsten Kaiser <just.for.lkml@googlemail.com>

Applied, thank you.

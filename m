From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: be more selective about FIFO watchdog
Date: Thu, 20 Sep 2007 14:30:46 -0700
Message-ID: <20070920143046.61fce43b@freepuppy.rosehill>
References: <20070920130349.252ecdb9@freepuppy.rosehill>
	<46F2DD41.30909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48872 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753359AbXITVbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 17:31:06 -0400
In-Reply-To: <46F2DD41.30909@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Sep 2007 16:51:13 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Be more selective about when to enable the ram buffer watchdog code.
> > It is unnecessary on XL A3 or later revs, and with Yukon FE
> > the buffer is so small (4K) that the watchdog detects false positives.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> With all the sky2 patches flying about, it would be wise to include 
> notes like "applies to 2.6.23-rc" or "net-2.6.24" after the standard 
> "---" terminator.
> 
> is this patch supposed to go on top of the sky2 patches that Linus just 
> pulled?
> 
> 
It can go after previous 6 on both 2.6.23-rc and net-2.6.24 (with fuzz)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

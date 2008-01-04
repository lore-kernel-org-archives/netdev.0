From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000_clean_tx_irq: Detected Tx Unit Hang - it's bug?
Date: Fri, 04 Jan 2008 12:11:15 -0800
Message-ID: <477E92E3.1000202@intel.com>
References: <477E2833.70301@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33693 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752593AbYADUMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 15:12:40 -0500
In-Reply-To: <477E2833.70301@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Badalian Vyacheslav wrote:
> Hello all.
> Some time in dmesg i see this:
> 
> [16121.400422] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [16121.400426]   Tx Queue             <0>
> [16121.400427]   TDH                  <28>
> [16121.400429]   TDT                  <28>
> [16121.400430]   next_to_use          <28>
> [16121.400431]   next_to_clean        <7d>
> [16121.400433] buffer_info[next_to_clean]
> [16121.400434]   time_stamp           <17b949>
> [16121.400435]   next_to_watch        <7d>
> [16121.400437]   jiffies              <17ba57>
> [16121.400438]   next_to_watch.status <1>

might be a bug. What kernel version are you using? it appears the tx handler was
just sitting idle and this message might be bogus, which is one of the things that
we fixed recently.

Auke

From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net: pktgen: fix null ptr deref in skb allocation
Date: Tue, 12 Jan 2016 09:32:44 -0800
Message-ID: <569538BC.7090202@gmail.com>
References: <20160111053844.3695.82965.stgit@john-Precision-Tower-5810> <20160111.174031.1199997012538036511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bogdan.hamciuc@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33508 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbcALRcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 12:32:55 -0500
Received: by mail-pa0-f43.google.com with SMTP id cy9so343043963pac.0
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 09:32:55 -0800 (PST)
In-Reply-To: <20160111.174031.1199997012538036511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-11 02:40 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Sun, 10 Jan 2016 21:38:44 -0800
> 
>> Fix possible null pointer dereference that may occur when calling
>> skb_reserve() on a null skb.
>>
>> Fixes: 879c7220e82 ("net: pktgen: Observe needed_headroom of the device")
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> I don't know how I missed that during review :-/

Well once you get pktgen running fast enough to get allocation
failures the occasional system halts are pretty hard to miss :)

> 
> Applied and queued up for -stable, thanks!
> 

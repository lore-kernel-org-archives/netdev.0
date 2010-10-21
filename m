From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: dead code in networking core
Date: Thu, 21 Oct 2010 17:47:01 +0200
Message-ID: <20101021154701.GA4654@riccoc20.at.omicron.at>
References: <20101020085229.4f908bcd@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42432 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881Ab0JUPqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:46:50 -0400
Received: by bwz18 with SMTP id 18so420574bwz.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 08:46:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101020085229.4f908bcd@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 20, 2010 at 08:52:29AM -0700, Stephen Hemminger wrote:
>   net/core/timestamping.o
>     skb_clone_tx_timestamp
>     skb_complete_tx_timestamp
> 
> Any plans to use these soon?

Yes, these are brand new functions needed for PTP hardware
timestamping support.

I have a patch series under active review on lkml. It will take time
to settle the issues, but people have clearing indicated wanting to
support PTP hardware clocks.

Richard

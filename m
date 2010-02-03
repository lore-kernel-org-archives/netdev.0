From: "Kevin Pedretti" <ktpedre@sandia.gov>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Tue, 2 Feb 2010 18:24:02 -0700
Message-ID: <1265160242.15726.20.camel@hawkeye.sandia.gov>
References: <20100202205845.GE5246@hawkeye.sandia.gov>
 <20100202.134251.15604523.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100202.134251.15604523.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you all for the review comments.  I believe most of the issues
have been addressed in the patch just posted.  I apologize if there are
still issues, and certainly appreciate further comments.

David Miller's comments:
1. Use u32, u16, etc.  -> Done.
2. Bad code formating -> Fixed, I believe. Went through everything.
3. Call netif_start_queue() after hw init -> Done.
4. Device only supports IPv4? -> Yes, that's correct. No IPv6 support.
The driver squashes everything but IPv4 in eth2ss().
5. No need for suspend/resume NOPs -> Done.  functions removed.

Randy Dunlap's comments:
1. Remove /** comments -> Done.
2. Odd spacing -> I'm not seeing this. Spacing looks correct to me.
3. Limit while (1) loops somehow -> Done. 
4. Limit while (1) in intr handler -> In practice we've never seen more
than a few packets processed per interrupt.

Ben Hutching's comments:
1. Spacing looks correct -> Thanks. 

Stephen Hemminger's comments:
1. Add ndo_validate_address -> Done
2. May want to use alloc_netdev() -> Didn't do this. Would there be a
substantial advantage to doing this?
3. memset() unnecessary -> removed

Kevin

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH,RFC] Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Fri, 8 Sep 2006 22:38:31 +0200
Message-ID: <20060908203831.GB23545@electric-eye.fr.zoreil.com>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060818212852.GA5379@xi.wantstofly.org> <20060820213558.GA13188@electric-eye.fr.zoreil.com> <20060904222715.GF3782@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:17058 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751215AbWIHUkg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 16:40:36 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20060904222715.GF3782@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> :
[...]
> I tried your series from step (1) plus my TxDesc change (so I didn't
> include the hunk from (2)), and that seems to work fine.  I.e. I don't
> need to disable error interrupts anymore to keep it working.
> 
> So really the only thing that would need addressing would be the TXDesc
> MMIO bug (either by using I/O accesses, or doing the top/bottom writes
> the other way round) and we can dump the vendor driver.

I'll turn the top/bottom write the other way around for it looks
like the less intrusive option so far.

The current r8169 serie stood long enough in -mm that I can ask Jeff
to pull it. The link management of the 8136 needs more work but it is
not a showstopper.

-- 
Ueimor

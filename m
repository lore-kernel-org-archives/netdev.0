From: Aubrey <aubreylee@gmail.com>
Subject: Re: Netpoll checksum issue
Date: Thu, 20 Apr 2006 09:54:54 +0800
Message-ID: <6d6a94c50604191854m73b241e3v104d713b7bb93674@mail.gmail.com>
References: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com>
	 <20060419103153.64ef0054@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:6478 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1750729AbWDTBy4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 21:54:56 -0400
Received: by nproxy.gmail.com with SMTP id l24so11516nfc
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2006 18:54:54 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060419103153.64ef0054@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/20/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> The changes to how hardware receive checksums are handled broke
> the netpoll checksum code (for CHECKSUM_HW).  Since this is not at
> all performance critical, try this patch. It changes to always to
> normal software checksum.
>
Hi Stephen - The patch doesn't work for my driver.

Hi Herbert - I'm working on blackfin uclinux platform. My network
driver is for blackfin on-chip EMAC. Of course it's open source, but
so far it's not committed into mainline tree. We can be found at here:
http://www.blackfin.uclinux.org

My driver didn't assign any value to skb->ip_summed,  and didn't
define tx/rx checksum routine like "e1000_rx_checksum", but it did
work before on 2.6.12. I'm trying to find what's broken.
Thanks,
-Aubrey

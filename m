From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: Fix multicast hash table handling
Date: Wed, 26 Mar 2008 08:34:23 +0100
Message-ID: <874paudjls.fsf@macbook.be.48ers.dk>
References: <1205878614-29065-1-git-send-email-jacmet@sunsite.dk>
	<47E9C0E3.6040404@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:4585 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbYCZHed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 03:34:33 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3910497fgb.17
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 00:34:32 -0700 (PDT)
In-Reply-To: <47E9C0E3.6040404@garzik.org> (Jeff Garzik's message of "Tue\, 25 Mar 2008 23\:20\:03 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Jeff" == Jeff Garzik <jeff@garzik.org> writes:

 Jeff> Peter Korsgaard wrote:
 >> The loop forgot to walk the net->mc_list list, so only the first
 >> multicast address was programmed into the hash table.
 >> 
 >> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
 >> ---
 >> drivers/net/usb/dm9601.c |    2 +-
 >> 1 files changed, 1 insertions(+), 1 deletions(-)

 Jeff> applied three patches.

Thanks!

 Jeff> Please number your patches in the future, to indicate the order of
 Jeff> application -- even if they are roughly independent, it helps to know
 Jeff> they are in the same patch series by some method other than just the
 Jeff> References RFC-822 header

Ok - Will do.

-- 
Bye, Peter Korsgaard

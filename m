From: Ben Dooks <ben@simtec.co.uk>
Subject: Re: [PATCH 2.6.32 3/3] net: Make ks8851 snl work under Beagle Zippy
 combo board
Date: Fri, 04 Dec 2009 10:20:14 +0000
Message-ID: <4B18E25E.7030808@simtec.co.uk>
References: <14385191E87B904DBD836449AA30269D021A42@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:36697 "EHLO
	ben-laptop.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752099AbZLDKTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 05:19:43 -0500
In-Reply-To: <14385191E87B904DBD836449AA30269D021A42@MORGANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ha, Tristram wrote:
> From: Tristram Ha <Tristram.Ha@micrel.com>
> 
> The Micrel KSZ8851 SNL Ethernet chip is used in the OMAP Beagle Zippy combo board.  Requesting interrupt using level triggering flag hangs the system because the interrupt handling routine is called continually.  Using edge triggering avoids this problem.  As a result, disabling interrupt may not be necessary.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>

Making this sort of change could impact other users. I'll
submit a patch to get the interrupt type properly and push
everything else i've got,

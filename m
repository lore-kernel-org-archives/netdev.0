From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [RFC] div64_64 support
Date: Mon, 26 Feb 2007 17:20:34 -0800
Message-ID: <45E38762.5040407@zytor.com>
References: <20070223170527.4ca695b2@freekitty>	<Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr> <20070226132834.70514f19@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:39698 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbXB0BVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 20:21:16 -0500
In-Reply-To: <20070226132834.70514f19@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> 
> Hmm. Those are the GCC internal versions, that are picked up but
> doing divide in place. Do we want to allow general 64 bit in kernel to
> be easily used? It could cause sloppy slow code, but it would look
> cleaner.
> 

... and it would handle datatypes which may be architecture-dependent a 
lot cleaner.

I thought the motivation for div64() was that a 64:32->32 divide could 
be done a lot faster on a number of platforms (including the important 
x86) than a generic 64:64->64 divide, but gcc doesn't handle the 
devolution automatically -- there is no such libgcc function.

	-hpa

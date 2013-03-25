From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/7] ip/xfrm: Extend SPI validity checking
Date: Mon, 25 Mar 2013 08:03:23 -0700
Message-ID: <20130325080323.238987de@nehalam.linuxnetplumber.net>
References: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:55265 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757292Ab3CYPDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 11:03:35 -0400
Received: by mail-pb0-f49.google.com with SMTP id um15so472661pbc.36
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 08:03:34 -0700 (PDT)
In-Reply-To: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Mar 2013 10:23:13 -0400
David Ward <david.ward@ll.mit.edu> wrote:

> A Security Policy Index (SPI) is not used with Mobile IPv6. IPComp
> uses a smaller 16-bit Compression Parameter Index (CPI) which is
> passed as the SPI value. Perform checks whenever specifying an ID.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

These all look fine to me, I will apply them in a couple of days
unless there is anybody who sees a compatibility problem with current usage.

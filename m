From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] net/ipv4/arp.c: Use the exported hex_asc from
	lib/hexdump.c instead
Date: Tue, 20 May 2008 15:40:12 -0700
Message-ID: <1211323212.5915.220.camel@brick>
References: <1211135864-8235-1-git-send-email-crquan@gmail.com>
	 <20080520.153611.204837174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: crquan@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:28878 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935182AbYETWkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 18:40:15 -0400
Received: by wr-out-0506.google.com with SMTP id c48so1267101wra.1
        for <netdev@vger.kernel.org>; Tue, 20 May 2008 15:40:14 -0700 (PDT)
In-Reply-To: <20080520.153611.204837174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-05-20 at 15:36 -0700, David Miller wrote:
> From: Denis Cheng <crquan@gmail.com>
> Date: Mon, 19 May 2008 02:37:44 +0800
> 
> > Here the local hexbuf is a duplicate of global const char hex_asc from
> > lib/hexdump.c, except the hex letters' cases:
> > 
> > const char hexbuf[] = "0123456789ABCDEF";
> > 
> > const char hex_asc[] = "0123456789abcdef";
> > 
> > and here to print HW addresses, the hex cases are not significant.
> > 
> > Signed-off-by: Denis Cheng <crquan@gmail.com>
> 
> Applied, thanks.

You may want to use the hex_asc_hi, hex_asc_lo helpers to do the
mask/shifts for you.

Harvey


From: Jim Westfall <jwestfall@surrealistic.net>
Subject: Re: [PATCH] llc: fix skb size for test responses
Date: Sun, 24 Feb 2008 21:04:21 -0800
Message-ID: <20080225050421.GY84358@surrealistic.net>
References: <20080224190758.GW84358@surrealistic.net> <20080224.185104.207884881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snapper.surrealistic.net ([67.40.222.186]:56756 "EHLO
	snapper.surrealistic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbYBYFEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 00:04:32 -0500
Content-Disposition: inline
In-Reply-To: <20080224.185104.207884881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote [02.24.08]:
> From: Jim Westfall <jwestfall@surrealistic.net>
> Date: Sun, 24 Feb 2008 11:07:58 -0800
> 
> > Hi
> > 
> > The llc test command is used for a layer2 ping and contains a variable 
> > length payload that we must include in the response.  Use the size of the 
> > received skb as the size of the skb we must allocate to hold the payload. 
> > 
> > This resolved an skb_over_panic(), when trying to copy the payload into 
> > what was a hard coded skb of size 128.
> > 
> > Signed-off-by: Jim Westfall <jwestfall@surrealistic.net>
> 
> Arnaldo, please review Jim's patch, thanks!

Our of curiosity did you all get my 2nd patch?  

Subject: [PATCH] llc: dont trust payload size on test cmd

I sent it a few minutes after this one, but seems like it never made it 
to the list.  My local smtp shows it was delivered sucussfully to 
vger.kernel.org.

thanks
jim

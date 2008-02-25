From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] llc: fix skb size for test responses
Date: Mon, 25 Feb 2008 11:06:52 -0300
Message-ID: <20080225140652.GC4022@ghostprotocols.net>
References: <20080224190758.GW84358@surrealistic.net> <20080224.185104.207884881.davem@davemloft.net> <20080225050421.GY84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jim Westfall <jwestfall@surrealistic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43425 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238AbYBYOG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 09:06:59 -0500
Content-Disposition: inline
In-Reply-To: <20080225050421.GY84358@surrealistic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sun, Feb 24, 2008 at 09:04:21PM -0800, Jim Westfall escreveu:
> David Miller <davem@davemloft.net> wrote [02.24.08]:
> > From: Jim Westfall <jwestfall@surrealistic.net>
> > Date: Sun, 24 Feb 2008 11:07:58 -0800
> > 
> > > Hi
> > > 
> > > The llc test command is used for a layer2 ping and contains a variable 
> > > length payload that we must include in the response.  Use the size of the 
> > > received skb as the size of the skb we must allocate to hold the payload. 
> > > 
> > > This resolved an skb_over_panic(), when trying to copy the payload into 
> > > what was a hard coded skb of size 128.
> > > 
> > > Signed-off-by: Jim Westfall <jwestfall@surrealistic.net>
> > 
> > Arnaldo, please review Jim's patch, thanks!
> 
> Our of curiosity did you all get my 2nd patch?  
> 
> Subject: [PATCH] llc: dont trust payload size on test cmd
> 
> I sent it a few minutes after this one, but seems like it never made it 
> to the list.  My local smtp shows it was delivered sucussfully to 
> vger.kernel.org.

I got it, but you made a mistake on the To: address:

From: Jim Westfall <jwestfall@surrealistic.net>
Subject: [PATCH] llc: dont trust payload size on test cmd
To: "To:netdev"@vger.kernel.org, acme@ghostprotocols.net

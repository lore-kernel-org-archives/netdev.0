From: Baruch Even <baruch@ev-en.org>
Subject: Re: Multicast and hardware checksum
Date: Fri, 08 Jun 2007 14:15:07 +0300
Message-ID: <46693A3B.70202@ev-en.org>
References: <E1HwXpK-0005RC-00@gondolin.me.apana.org.au> <46693743.7090100@ev-en.org> <20070608110621.GA23842@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:48030
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966473AbXFHLPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 07:15:47 -0400
In-Reply-To: <20070608110621.GA23842@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Jun 08, 2007 at 02:02:27PM +0300, Baruch Even wrote:
>> As far as IGMP and multicast handling everything works, the packets are 
>> even forwarded over the ppp links but they arrive to the client with a 
>> bad checksum. I don't have the trace in front of me but I believe it was 
>> the UDP checksum that failed.
> 
> What kind of a ppp device is this?
> 
> If you run a tcpdump either side of the ppp link do you see the same
> UDP checksum value?

This is a pptp link. I've checked the checksum on the receive side, I 
don't know on the sender side and I'll only be able to try it on Sunday.

Baruch

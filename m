From: Baruch Even <baruch@ev-en.org>
Subject: Re: Multicast and hardware checksum
Date: Fri, 08 Jun 2007 14:02:27 +0300
Message-ID: <46693743.7090100@ev-en.org>
References: <E1HwXpK-0005RC-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:25868
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938077AbXFHLDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 07:03:12 -0400
In-Reply-To: <E1HwXpK-0005RC-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Baruch Even <baruch@ev-en.org> wrote:
>> I have a machine on which I have an applications that sends multicast 
>> through eth interface with hardware tx checksum enabled. On the same 
>> machine I have mrouted running that routes the multicast traffic to a 
>> set of ppp interfaces. The packets that are received by the client have 
>> their checksum fixed on some number which is incorrect. If I disable tx 
>> checksum on the eth device the packets arrive with the proper checksum.
> 
> Where is the client? On the same machine or behind a PPP link?

The clients are behind the ppp links.

As far as IGMP and multicast handling everything works, the packets are 
even forwarded over the ppp links but they arrive to the client with a 
bad checksum. I don't have the trace in front of me but I believe it was 
the UDP checksum that failed.

Baruch



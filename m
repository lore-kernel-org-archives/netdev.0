From: Marco Berizzi <pupilla@hotmail.com>
Subject: RE: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100
 ss:esp 0068:c03a1e5c
Date: Thu, 1 May 2008 21:14:57 +0200
Message-ID: <BAY103-W321E5B4FC2E7D5EE201E07B2DB0@phx.gbl>
References: <E1JrXMB-00028Q-00@gondolin.me.apana.org.au>
 <BAY103-DAV8F11938C76B8B9245D864B2DB0@phx.gbl>
 <20080501140911.GB9055@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s37.bay0.hotmail.com ([65.54.246.237]:42312 "EHLO
	bay0-omc3-s37.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756426AbYEATO6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 15:14:58 -0400
In-Reply-To: <20080501140911.GB9055@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Herbert Xu wrote:

> On Thu, May 01, 2008 at 02:59:42PM +0200, Marco Berizzi wrote:
>>
>> Yes indeed, this box is in the middle of a very poorly designed
>> network: it is the default gateway for lan clients, but it is
>> routing back all traffic to another lan box except for ipsec
>> traffic.
> 
> OK I don't see any rerouting actions in your rule dump.
> 
> Is your box SMP

nope, it is an old PII or PIII 

> or have you enabled preemption? 

.config is posted here:

http://www.ussg.iu.edu/hypermail/linux/kernel/0804.3/1763.html

CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
_________________________________________________________________
Discover the new Windows Vista
http://search.msn.com/results.aspx?q=windows+vista&mkt=en-US&form=QBRE
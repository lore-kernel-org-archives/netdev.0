From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Tue, 10 Apr 2012 18:28:47 -0700
Message-ID: <20120410182847.45e47c5e@nehalam.linuxnetplumber.net>
References: <20120403113751.21fd0b17@s6510.linuxnetplumber.net>
	<4F7CD4BC.4000006@enea.com>
	<20120404165559.5223ab95@s6510.linuxnetplumber.net>
	<20120404.202109.2046106039992811660.davem@davemloft.net>
	<4F7F10FC.3020308@enea.com>
	<1333731991.3282.17.camel@deadeye>
	<20120406111912.172bb1fb@nehalam.linuxnetplumber.net>
	<4F84CA36.7020209@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46401 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756011Ab2DKB2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 21:28:49 -0400
In-Reply-To: <4F84CA36.7020209@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 3) My feeble suggestion to cast icmp_hdr() to (char *) is of course even worse (it doesn't
> even avoid the erroneous cast in the first place).
> 
> So what do we do?
> 

Reading Documentation/unalgined-memory-access.txt suggests that you
probably should copy the skb before passing up the stack (if necessary).
That is safe (but slightly slower).

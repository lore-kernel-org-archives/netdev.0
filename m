From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Tue, 22 Apr 2008 16:50:41 -0400
Message-ID: <480E4FA1.5020508@garzik.org>
References: <20080412115950.1cbb9cfa@core>	<m33apqomgf.fsf@maximus.localdomain>	<m33apjp32f.fsf@maximus.localdomain>	<20080418.153256.253949503.davem@davemloft.net>	<m3ve2b9qe8.fsf@maximus.localdomain> <480CEB7D.8070702@katalix.com> <m33apdyajf.fsf@maximus.localdomain> <480E5CB3.2080003@microgate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	James Chapman <jchapman@katalix.com>,
	David Miller <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Fulghum <paulkf@microgate.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35518 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752061AbYDVUu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2008 16:50:59 -0400
In-Reply-To: <480E5CB3.2080003@microgate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Fulghum wrote:
> Krzysztof Halasa wrote:
>> It's complex, I think kernel interface to generic HDLC would mean more
>> code than PPP implementation required for fixed lines.
>> Additional requirement - userspace daemon with additional plugin - may
>> not be the best thing for fixed lines either.
>>
>> That would break backward compatibility, too.
> 
> I maintain both pppd and generic HDLC PPP
> interfaces for the synclink drivers.
> I would like to have a single PPP implementation,
> but what Krzysztof writes about compatibility and complexity
> (both in coding and user configuration) is a real issue.
> 
> Many customers who choose to use generic HDLC PPP are *dead*
> set against the added complexity and (user space)
> components of using pppd even though it has more features.
> I say that having tried to persuade such users to use pppd.
> The response is usually "support the simpler generic
> HDLC PPP way of doing things or we will go elsewhere".
> Others require the extra features of pppd.
> 
> I understand customer desires are not always rational
> or a primary concern when making these architectural
> decisions, but I know forcing the extra complexity and
> components of pppd on generic HDLC users will cause a
> lot of anger and defections.

The fact that Krzysztof's solution was _small_ and _clean_ and easily 
maintainable was the reason I merged it [into my tree].

IMO sometimes "one size fits all" is not the best solution.

	Jeff




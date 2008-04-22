From: Paul Fulghum <paulkf@microgate.com>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Tue, 22 Apr 2008 15:46:27 -0600
Message-ID: <480E5CB3.2080003@microgate.com>
References: <20080412115950.1cbb9cfa@core>	<m33apqomgf.fsf@maximus.localdomain>	<m33apjp32f.fsf@maximus.localdomain>	<20080418.153256.253949503.davem@davemloft.net>	<m3ve2b9qe8.fsf@maximus.localdomain> <480CEB7D.8070702@katalix.com> <m33apdyajf.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>,
	David Miller <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk,
	akpm@linux-foundation.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-70-250-156-241.dsl.austtx.swbell.net ([70.250.156.241]:41434
	"EHLO gw.microgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762800AbYDVU4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 16:56:08 -0400
In-Reply-To: <m33apdyajf.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> It's complex, I think kernel interface to generic HDLC would mean more
> code than PPP implementation required for fixed lines.
> Additional requirement - userspace daemon with additional plugin - may
> not be the best thing for fixed lines either.
> 
> That would break backward compatibility, too.

I maintain both pppd and generic HDLC PPP
interfaces for the synclink drivers.
I would like to have a single PPP implementation,
but what Krzysztof writes about compatibility and complexity
(both in coding and user configuration) is a real issue.

Many customers who choose to use generic HDLC PPP are *dead*
set against the added complexity and (user space)
components of using pppd even though it has more features.
I say that having tried to persuade such users to use pppd.
The response is usually "support the simpler generic
HDLC PPP way of doing things or we will go elsewhere".
Others require the extra features of pppd.

I understand customer desires are not always rational
or a primary concern when making these architectural
decisions, but I know forcing the extra complexity and
components of pppd on generic HDLC users will cause a
lot of anger and defections.

-- 
Paul Fulghum
Microgate Systems, Ltd.

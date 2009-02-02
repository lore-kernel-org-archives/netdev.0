From: Andrew Walrond <andrew@walrond.org>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Mon, 02 Feb 2009 21:13:11 +0000
Message-ID: <498761E7.3080006@walrond.org>
References: <20090128.122924.106238702.davem@davemloft.net>	<alpine.LSU.2.00.0901300510310.22910@fbirervta.pbzchgretzou.qr>	<4986CC6D.4090904@walrond.org> <20090202.120507.152093960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, sam@ravnborg.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from marvin.heresymail.org ([87.106.62.5]:57523 "EHLO
	marvin.heresymail.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753579AbZBBVNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:13:17 -0500
In-Reply-To: <20090202.120507.152093960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>
> There isn't anything we can really do about these cases.
>
> No matter what we do, we break the userland build in one way or
> another.
>   
What exactly is the purpose of the kernel headers? Are there some 
definitions in the kernel headers that will never be available from 
glibc? Is it perhaps possible to work towards exporting kernel headers 
for the sole purpose of building glibc, and all other packages should be 
able to build against glibc's headers?

Andrew Walrond

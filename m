From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: use %pI6c for printing IPv6 addresses
Date: Sun, 08 May 2011 15:50:56 -0700 (PDT)
Message-ID: <20110508.155056.15256791.davem@davemloft.net>
References: <20110503212340.GA25293@p183>
	<1304460714.1788.40.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52512
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753748Ab1EHWv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:51:29 -0400
In-Reply-To: <1304460714.1788.40.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 03 May 2011 15:11:54 -0700

> On Wed, 2011-05-04 at 00:23 +0300, Alexey Dobriyan wrote:
>> I don't know why %pI6 doesn't compress, but the format specifier is
>> kernel-standard, so use it.
> 
> Because seq_printf output using %pI6 has a known
> output style and shouldn't be changed to avoid
> breaking user applications.

I've applied Alexey's patch to net-next-2.6

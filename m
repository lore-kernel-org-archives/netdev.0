From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] pktgen: use %pI6c for printing IPv6 addresses
Date: Tue, 03 May 2011 15:11:54 -0700
Message-ID: <1304460714.1788.40.camel@Joe-Laptop>
References: <20110503212340.GA25293@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1201 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888Ab1ECWLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 18:11:55 -0400
In-Reply-To: <20110503212340.GA25293@p183>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 00:23 +0300, Alexey Dobriyan wrote:
> I don't know why %pI6 doesn't compress, but the format specifier is
> kernel-standard, so use it.

Because seq_printf output using %pI6 has a known
output style and shouldn't be changed to avoid
breaking user applications.



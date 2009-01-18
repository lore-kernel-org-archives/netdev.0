From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 11/34]bnx2x: Endianness issues
Date: Sun, 18 Jan 2009 11:59:08 -0500
Message-ID: <20090118165908.GA11345@infradead.org>
References: <1231951395.11301.132.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:46421 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107AbZARQ7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 11:59:10 -0500
Content-Disposition: inline
In-Reply-To: <1231951395.11301.132.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 06:43:15PM +0200, Eilon Greenstein wrote:
> Adding missing le_to_cpu and disabling wrong HW endianity flag (the two complete
> each other)

Did you run sparse over the driver to verify you've sorted out all
endianess issues?


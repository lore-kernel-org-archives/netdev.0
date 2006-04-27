From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 20/32] rt2x00: byte ordering correctness
Date: Thu, 27 Apr 2006 23:13:21 +0100
Message-ID: <20060427221321.GB22135@infradead.org>
References: <200604280003.12743.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40680 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751816AbWD0WNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 18:13:22 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200604280003.12743.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 12:03:12AM +0200, Ivo van Doorn wrote:
> From: Ivo van Doorn <IvDoorn@gmail.com>
> 
> Fix various little/big endian conversions.
> rt2500pci should use cpu_to_le32 and rt2500usb should not.

While you're at it can you add __be* annotations to the hardware
datastructures so the endianess handling can be verified using sparse?

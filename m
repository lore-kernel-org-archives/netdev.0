From: Michael-Luke Jones <mlj28@cam.ac.uk>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 16 May 2007 08:35:01 +0100
Message-ID: <6621E298-9B98-478F-AD6E-23559BCB4FF3@cam.ac.uk>
References: <464034CF.20700@wpkg.org> <20070516071300.GB14222@infradead.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tomasz Chmielewski <mangoo@wpkg.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppsw-4.csi.cam.ac.uk ([131.111.8.134]:52192 "EHLO
	ppsw-4.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756414AbXEPHfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 03:35:05 -0400
In-Reply-To: <20070516071300.GB14222@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16 May 2007, at 08:13, Christoph Hellwig wrote:

> Not even trying to support LE is a clear merge blocker.  Maybe  
> Krzysztof
> can't actually test it himself, which is fine - but not even  
> pretending
> to be endian clean is not what proper Linux drivers do.

w.r.t this comment, a working implementation LE implementation can be  
viewed here:

http://www.hohnstaedt.de/ixp_npe/0.3.1/ixp4xx_npe_driver-0.3.1.diff

Search in this file for "swap the payload of the SKB" (it's in  
mac_driver.c)

Michael-Luke Jones


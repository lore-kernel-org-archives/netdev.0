From: Michael-Luke Jones <mlj28@cam.ac.uk>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 16 May 2007 11:20:10 +0100
Message-ID: <D85F3D39-A8C9-4A1A-B88F-9500355B4747@cam.ac.uk>
References: <464034CF.20700@wpkg.org> <20070516071300.GB14222@infradead.org> <20070516094100.GB16262@xi.wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Tomasz Chmielewski <mangoo@wpkg.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppsw-4.csi.cam.ac.uk ([131.111.8.134]:39925 "EHLO
	ppsw-4.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757714AbXEPKUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 06:20:12 -0400
In-Reply-To: <20070516094100.GB16262@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16 May 2007, at 10:41, Lennert Buytenhek wrote:
> Making a driver work in both modes
> of operation is generally not just an issue of adding a couple of
> be32_to_cpu()s in the right places.

While this comment is technically correct, Christian's driver  
achieves endian agnostic operation with only 10 additional lines of  
code [1].

Thus, there is no reason to assume that gaining LE support will be a  
major issue.

Michael-Luke

[1] http://www.hohnstaedt.de/ixp_npe/0.3.1/ixp4xx_npe_driver-0.3.1.diff
Search in this file for "swap the payload of the SKB" (it's in  
mac_driver.c)


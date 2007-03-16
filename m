From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] s2io: add PCI error recovery support
Date: Fri, 16 Mar 2007 14:49:41 -0500
Message-ID: <20070316194941.GP5151@austin.ibm.com>
References: <78C9135A3D2ECE4B8162EBDCE82CAD7701481EE3@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wen Xiong <wenxiong@us.ibm.com>, linux-kernel@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:41865 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753630AbXCPTto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 15:49:44 -0400
Content-Disposition: inline
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7701481EE3@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 05:33:39PM -0500, Ramkrishna Vepa wrote:
> Comments on this patch -
> 
> 1. device_close_flag is unused and is not required.

I'll submit a patch to strip this out sometime next week.

> 2. s2io_reset can fail to reset the device. 

I thought I'd seen this occasionally, and its on my to-do list
to look into this further.

> Ideally s2io_reset should
> return a failure in this case (return is void now) 

Would you care to provide a patch that did this? I could 
experiment a bit, and try to do this myself; but I really
don't know this hardware, or this driver, that well.

--linas



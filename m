From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/7] cxgb3 - Fix SGE page management
Date: Mon, 28 May 2007 18:34:06 -0400
Message-ID: <465B58DE.1010308@garzik.org>
References: <20070526225947.12097.82363.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48848 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750707AbXE1WeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 18:34:09 -0400
In-Reply-To: <20070526225947.12097.82363.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Streamline page management on RX.
> Fix dma mappings.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

NAK #1:  "streamline" is not a bug-fixes-only change, which is the only 
type of change appropriate for 2.6.22-rc.

NAK #2:  You should use the page_address(page) accessor rather than 
creating a struct member in the same struct as your page, solely to 
contain the virtual address.



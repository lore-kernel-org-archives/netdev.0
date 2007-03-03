From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/3] NetXen: Make driver use multi PCI functions
Date: Fri, 02 Mar 2007 20:05:16 -0500
Message-ID: <45E8C9CC.7030005@garzik.org>
References: <200702281319.l1SDJ2FV004424@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netxenproj@linsyssoft.com, rob@netxen.com
To: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55430 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992823AbXCCBFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:05:18 -0500
In-Reply-To: <200702281319.l1SDJ2FV004424@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Mithlesh Thukral wrote:
> NetXen: Make driver use multi PCI functions.
> 
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> 
> ---
> 
>  netxen_nic.h          |  126 +++++-------
>  netxen_nic_ethtool.c  |   80 +++----
>  netxen_nic_hdr.h      |    8 
>  netxen_nic_hw.c       |  213 +++++++++++++++-----
>  netxen_nic_hw.h       |   18 -
>  netxen_nic_init.c     |  115 +++-------
>  netxen_nic_isr.c      |   80 +++----
>  netxen_nic_main.c     |  523 +++++++++++++++++++++++++-------------------------
>  netxen_nic_niu.c      |   27 +-
>  netxen_nic_phan_reg.h |  125 -----------
>  10 files changed, 631 insertions(+), 684 deletions(-)

all three patches in this patchset contained nothing but one-line 
summaries of the changes included in them, and are overall very poorly 
and vaguely described.

This patch is far too big, with far too little description and 
justification to go along with it.

If you are not going to make the effort to write a paragraph or two 
describing such huge changes, then I'm not going to make the effort to 
review and apply it.  NAK.



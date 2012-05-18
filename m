From: "Sullivan, Catherine" <catherine.sullivan@intel.com>
Subject: RE: [NET_NEXT RFC PATCH 1/3] ixgbe: add debugfs support
Date: Fri, 18 May 2012 17:10:56 +0000
Message-ID: <F1C1314B3E1AB7499F9BF2A5F0F033EC14D002@FMSMSX104.amr.corp.intel.com>
References: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
	<20120509230940.31910.64408.stgit@localhost6.localdomain6>
 <20120509161029.4a8f644b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51320 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965071Ab2ERRK7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 13:10:59 -0400
In-Reply-To: <20120509161029.4a8f644b@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Wednesday, May 09, 2012 4:10 PM
> 
> On Wed, 09 May 2012 16:09:40 -0700
> Catherine Sullivan <catherine.sullivan@intel.com> wrote:
> 
> > This patch adds debugfs support to the ixgbe driver to give users the
> > ability to access kernel information and to simulate kernel events.
> >
> > The filesystem is set up in the following driver/PCI-instance
> > hierarchy:
> > <debugfs>
> >    |-- ixgbe
> > 	|-- PCI instance
> > 	|	|-- attribute files
> > 	|-- PCI instance
> > 		|-- attribute files
> >
> > Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> 
> This should be an optional configuration since it is meant for special
> case usage. See SKY2_DEBUG

After looking through the kernel, there doesn't seem to be a clear precedence for this. As was pointed out, SKY2_DEBUG is an optional configuration on its own. However regmap uses debugfs, and it is only optional based on CONFIG_DEBUG_FS, which is how this patch is currently set up. This patch does not have much overhead and we would prefer that it be enabled with CONFIG_DEBUG_FS. 

From: "Sullivan, Catherine" <catherine.sullivan@intel.com>
Subject: RE: [NET_NEXT RFC PATCH 2/3] ixgbe: added netdev_ops file to debugfs
Date: Thu, 10 May 2012 20:28:28 +0000
Message-ID: <F1C1314B3E1AB7499F9BF2A5F0F033EC14A8F3@FMSMSX104.amr.corp.intel.com>
References: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
	<20120509230945.31910.48302.stgit@localhost6.localdomain6>
 <20120509161320.37fcb705@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35068 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755159Ab2EJU2i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 16:28:38 -0400
In-Reply-To: <20120509161320.37fcb705@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Could you point me to where this is available in sysfs please? I'm not familiar with it. 

Thanks, 
Catherine

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Wednesday, May 09, 2012 4:13 PM
To: Sullivan, Catherine
Cc: netdev@vger.kernel.org
Subject: Re: [NET_NEXT RFC PATCH 2/3] ixgbe: added netdev_ops file to debugfs

On Wed, 09 May 2012 16:09:45 -0700
Catherine Sullivan <catherine.sullivan@intel.com> wrote:

> Added the netdev_ops file to debugfs with a command to call the 
> ndo_tx_timeout function to give users the ability to simulate a 
> tx_timeout call made by the kernel.
> 
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>

What is the justification for creating a new API here?

Your exposing only one thing 'tx_timeout' and that is a generic property of the device (not ixgbe specific). That value is already available via sysfs.

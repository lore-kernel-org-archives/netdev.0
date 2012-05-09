From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [NET_NEXT RFC PATCH 2/3] ixgbe: added netdev_ops file to
 debugfs
Date: Wed, 9 May 2012 16:13:20 -0700
Message-ID: <20120509161320.37fcb705@nehalam.linuxnetplumber.net>
References: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
	<20120509230945.31910.48302.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Catherine Sullivan <catherine.sullivan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42419 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759043Ab2EIXNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 19:13:23 -0400
In-Reply-To: <20120509230945.31910.48302.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 May 2012 16:09:45 -0700
Catherine Sullivan <catherine.sullivan@intel.com> wrote:

> Added the netdev_ops file to debugfs with a command to call the
> ndo_tx_timeout function to give users the ability to simulate a
> tx_timeout call made by the kernel.
> 
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>

What is the justification for creating a new API here?

Your exposing only one thing 'tx_timeout' and that is a generic property
of the device (not ixgbe specific). That value is already available via
sysfs.

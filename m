From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [NET_NEXT RFC PATCH 3/3] ixgbe: added reg_ops file to debugfs
Date: Wed, 9 May 2012 16:14:49 -0700
Message-ID: <20120509161449.43704ea7@nehalam.linuxnetplumber.net>
References: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
	<20120509230950.31910.6032.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Catherine Sullivan <catherine.sullivan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42562 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759093Ab2EIXOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 19:14:52 -0400
In-Reply-To: <20120509230950.31910.6032.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 May 2012 16:09:50 -0700
Catherine Sullivan <catherine.sullivan@intel.com> wrote:

> Added the reg_ops file to debugfs with commands to read and write
> a register to give users the ability to read and write individual
> registers on the fly.
> 
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> ---
> 
>  drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c |  112 ++++++++++++++++++++++
>  1 files changed, 112 insertions(+), 0 deletions(-)
> 

Aren't these registers already in ethtool? You are also
allowing write without any security checking.

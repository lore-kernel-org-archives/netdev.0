From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next] iproute2: Add new command to IP link to
 enable/disable VF spoof check
Date: Sun, 25 Sep 2011 10:23:53 -0700
Message-ID: <20110925102353.602d239b@s6510.linuxnetplumber.net>
References: <1316938998-29855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg Rose <gregory.v.rose@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54301 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113Ab1IYRXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Sep 2011 13:23:55 -0400
In-Reply-To: <1316938998-29855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Sep 2011 01:23:18 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Add IP link command parsing for VF spoof checking enable/disable
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

See my comments about ABI compatibility. Can't just grow size of structure.
Need to have new version of iproute work with older kernels.

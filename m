From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for
 physical identification
Date: Mon, 11 Apr 2011 16:26:01 -0700
Message-ID: <20110411162601.6686f169@nehalam>
References: <20110411231635.9339.36369.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50496 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab1DKX0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 19:26:06 -0400
In-Reply-To: <20110411231635.9339.36369.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Apr 2011 16:16:35 -0700
Bruce Allan <bruce.w.allan@intel.com> wrote:

> When physical identification of an adapter is done by toggling the
> mechanism on and off through software utilizing the .set_phys_id operation,
> it is done with a fixed duration for both on and off states.  Some drivers
> may want to set a custom duration for the on/off intervals.  This patch
> changes the API so the return code from the driver's entry point can
> specify the interval duration as a positive number; -EINVAL is still
> allowed in order to use the default single on/off interval per second.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>

IMHO this is -EOVERKILL.

-- 

From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] acxsm: Reduce the number of ACX_PACKED instructions
Date: Thu, 13 Apr 2006 09:08:05 -0400
Message-ID: <20060413130800.GA25854@tuxdriver.com>
References: <11433168763687-git-send-email-carlos@cmartin.tk> <20060412205756.GD12788@tuxdriver.com> <200604131533.57478.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Carlos Martin <carlos@cmartin.tk>, netdev@vger.kernel.org,
	acx100-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:50950 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S964921AbWDMNI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 09:08:59 -0400
To: Denis Vlasenko <vda@ilport.com.ua>
Content-Disposition: inline
In-Reply-To: <200604131533.57478.vda@ilport.com.ua>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2006 at 03:33:57PM +0300, Denis Vlasenko wrote:

> Did you rename softmac branch again?

I'm trying to reduce the branches.  Some/most of what was the softmac
branch has been merged upstream.  The tiacx and prism54usb drivers
remain in wireless-2.6 under the "master" branch.

BTW, the consensus at the wifi summit was that the remaining softmac
drivers should be merged upstream as sson as the basic coding issues
(compiles w/o warnings, follows kernel style, etc) are resolved.
Actually "working" is not a solid requirement.

With that in mind, I would appreciate it if you (and any other
interested party) would begin reviewing the code with the intent to
get it merged in the next cycle.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com

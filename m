From: Andi Kleen <andi@firstfloor.org>
Subject: Please promote b1d670f10e80 to 2.6.37/stable to fix gcc mainline build
Date: Fri, 10 Dec 2010 22:18:53 +0100
Message-ID: <87aakdwcle.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:43427 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755549Ab0LJVS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 16:18:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Without this patch a gcc mainline kernel build fails. This is currently only
fixed in net-next. Could the patch please be promoted to 2.6.37 and
ideally for stable too?

Thanks,

-Andi

commit b1d670f10e8078485884f0cf7e384d890909aeaa
Author: Greg Rose <gregory.v.rose@intel.com>
Date:   Tue Nov 16 19:41:36 2010 -0800

    Remove extra struct page member from the buffer info structure
    
    declaration.
    
    Reported-by: Andi Kleen <andi@firstfloor.org>
    Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
    Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>


-- 
ak@linux.intel.com -- Speaking for myself only.

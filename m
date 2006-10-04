From: Steve Fox <drfickle@us.ibm.com>
Subject: Re: 2.6.18-mm3 oops in xfrm_register_mode
Date: Wed, 04 Oct 2006 16:02:11 -0500
Message-ID: <1159995731.28106.82.camel@flooterbu>
References: <20061003001115.e898b8cb.akpm@osdl.org>
	 <4523CFEF.6000007@us.ibm.com>  <20061004095703.5c843514.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:64403 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751126AbWJDVCP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 17:02:15 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061004095703.5c843514.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 09:57 -0700, Andrew Morton wrote:

> You might well find this bisection lands you on origin.patch.  ie: a
> mainline bug.  I note that David merged a few more xfrm fixes this morning.
> 
> So to confirm that, first test just origin.patch and if that fails, test
> git-of-the-moment.  If that doesn't fail, they fixed it.

origin.patch from --m3 failed. Unfortunately so did a fresh clone of
Linus's git tree.

-- 

Steve Fox
IBM Linux Technology Center

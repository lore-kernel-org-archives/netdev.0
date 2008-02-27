From: James Morris <jmorris@namei.org>
Subject: Re: [2.6 patch] selinux/netlabel.c should #include "netlabel.h"
Date: Thu, 28 Feb 2008 09:16:18 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0802280916020.19162@us.intercode.com.au>
References: <20080227212042.GK29269@cs181133002.pp.htv.fi>
 <200802271642.57556.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Adrian Bunk <bunk@kernel.org>, sds@tycho.nsa.gov,
	eparis@parisplace.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:42553 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757875AbYB0WRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 17:17:46 -0500
In-Reply-To: <200802271642.57556.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Feb 2008, Paul Moore wrote:

> On Wednesday 27 February 2008 4:20:42 pm Adrian Bunk wrote:
> > Every file should include the headers containing the externs for its
> > global code.
> >
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> It doesn't _need_ the file in the strictest sense, the header file is 
> just there for the core SELinux code to call into the NetLabel/SELinux 
> glue code (what is in security/selinux/netlabel.c).  However, if this 
> is to conform better to kernel coding policy (I assume that is the case 
> here?) then that is fine with me.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Applied to 
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-2.6.git#next

-- 
James Morris
<jmorris@namei.org>

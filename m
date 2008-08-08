From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Fri, 8 Aug 2008 16:15:08 -0700
Message-ID: <20080808231508.GB13158@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200808082109.47284.wolfgang.walter@stwm.de> <20080808193252.GD607@linux-os.sc.intel.com> <200808090110.42391.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46234 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533AbYHHXPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 19:15:09 -0400
Content-Disposition: inline
In-Reply-To: <200808090110.42391.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2008 at 04:10:42PM -0700, Wolfgang Walter wrote:
> By the way, if padlock is used from userspace, could this be aproblem, too? I
> mean not via the kernel crypto layer but directly. I think these extensions
> are not restricted to a privileged user.

No. Userspace will not have any such issue. Kernel is special, as it
has to preserve the user-space context and also use these instructions
for its own kernel purpose.

It is ok to get a spurious DNA from userland.

thanks,
suresh

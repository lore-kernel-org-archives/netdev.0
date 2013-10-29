From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] libertas: potential oops in debugfs
Date: Tue, 29 Oct 2013 23:09:24 +0300
Message-ID: <20131029200924.GF20521@mwanda>
References: <20131025144452.GA28451@ngolde.de>
 <20131029190641.GB21820@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, security@kernel.org,
	Nico Golde <nico@ngolde.de>, Fabian Yamaguchi <fabs@goesec.de>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20233 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab3J2UKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 16:10:15 -0400
Content-Disposition: inline
In-Reply-To: <20131029190641.GB21820@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 10:06:41PM +0300, Dan Carpenter wrote:
> If we do a zero size write then it will oops.  This can only be
> triggered by root.
> 

This one isn't right...  Sorry for that.  We do need to fix the while
loop.  I wasn't thinking.

I will resend.

regards,
dan carpenter

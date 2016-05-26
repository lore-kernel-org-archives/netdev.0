From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [patch] ptp: oops in ptp_ioctl()
Date: Thu, 26 May 2016 19:42:26 +0200
Message-ID: <20160526174226.GA1997@localhost.localdomain>
References: <20160526064622.GA6776@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Muhammad Falak R Wani <falakreyaz@gmail.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35087 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbcEZRmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 13:42:31 -0400
Content-Disposition: inline
In-Reply-To: <20160526064622.GA6776@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 09:46:22AM +0300, Dan Carpenter wrote:
> If we pass ERR_PTR(-EFAULT) to kfree() then it's going to oops.

Thanks for catching this.

Acked-by: Richard Cochran <richardcochran@gmail.com>
